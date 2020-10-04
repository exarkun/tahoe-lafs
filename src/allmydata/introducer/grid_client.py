import attr

from yaml import (
    safe_load,
)

from twisted.application.service import (
    MultiService,
)
from twisted.application.internet import (
    TimerService,
)

from foolscap.furl import (
    decode_furl,
    encode_furl,
)

from ..util.eliotutil import (
    inline_callbacks,
)

from allmydata.uri import (
    from_string,
)
from allmydata.interfaces import (
    IImmutableFileURI,
)

from .http_client import (
    DataSource,
)


@attr.s
class GridIntroducerClient(MultiService, object):
    reactor = attr.ib()
    announcements_cap = attr.ib()
    storage_furls = attr.ib()

    announcements = attr.ib(default=attr.Factory(DataSource))

    # compatibility with the IntroducerClient interface
    def subscribe_to(self, service_name, callback):
        self.announcements.subscribe(
            lambda (key_s, ann): (
                callback(key_s, ann)
                if ann.get(u"service-name") == service_name
                else None
            ),
        )

    @classmethod
    def from_config(cls, reactor, grid):
        parts = grid.split(u";")
        cap = from_string(parts.pop(0))
        if not IImmutableFileURI.providedBy(cap):
            raise ValueError(
                "Required immutable file cap, got {!r}".format(cap.to_string()),
            )
        return cls(
            reactor,
            cap,
            list(map(decode_furl, parts)),
        )

    def __attrs_post_init__(self):
        super(GridIntroducerClient, self).__init__()
        svc = TimerService(
            60,
            self._poll_announcements,
        )
        svc.clock = self.reactor
        svc.setServiceParent(self)

    def startService(self):
        super(GridIntroducerClient, self).startService()
        for n, storage_furl in enumerate(self.storage_furls):
            server_id = b"v0-bootstrap-{}".format(n)
            ann = {
                u"service-name": u"storage",
                u"anonymous-storage-FURL": encode_furl(*storage_furl),
            }
            self.announcements.publish((server_id, ann))

    @inline_callbacks
    def _poll_announcements(self):
        # self.parent is _Client!  And when we started, we made sure to inform
        # it of all the bootstrap storage fURLs we have.  So either storage is
        # accessible now or we can't ever make it accessible.
        print("grid introducer going to poll")
        announcements_node = self.parent.create_node_from_uri(
            write_uri=None,
            read_uri=self.announcements_cap.to_string(),
        )
        consumer = StringConsumer()
        try:
            yield announcements_node.read(consumer)
        except Exception as e:
            print("GridIntroducerClient: {}".format(e))
        else:
            body = consumer.data
            print("Body is: {!r}".format(body))
            announcements = safe_load(body)
            for key_s, ann in announcements.items():
                print("Annoucement: {!r} {!r}".format(key_s, ann))
                self.announcements.publish((key_s.encode("ascii"), ann))


class StringConsumer(object):
    data = b""

    def registerProducer(self, producer, streaming):
        self.streaming = streaming
        self.producer = producer
        if not self.streaming:
            producer.resumeProducing()

    def unregisterProducer(self):
        del self.producer, self.streaming

    def write(self, data):
        self.data += data
        self.producer.resumeProducing()
