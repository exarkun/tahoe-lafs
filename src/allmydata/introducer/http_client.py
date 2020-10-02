
from json import (
    loads,
)

from eliot import (
    start_action,
)

from twisted.web.http import (
    OK,
)
from twisted.web.client import (
    readBody,
)
from twisted.internet.defer import (
    returnValue,
)
from twisted.application.service import (
    MultiService,
)
from twisted.application.internet import (
    TimerService,
)

import attr

from ..util.eliotutil import (
    inline_callbacks,
)



@inline_callbacks
def get_announcements(agent, url):
    response = yield agent.request(b"GET", url.to_text().encode("ascii"))
    body = yield readBody(response)
    if response.code != OK:
        raise Exception(
            "Got HTTP status {} (expected OK)".format(
                response.code,
            ),
            body,
        )
    announcements = loads(body)
    returnValue(announcements)

@attr.s
class DataSource(object):
    _subscribers = attr.ib(default=attr.Factory(list))

    def subscribe(self, callback):
        self._subscribers.append(callback)

    def publish(self, event):
        for s in self._subscribers:
            try:
                s(event)
            except Exception as e:
                print(e)

@attr.s
class HTTPIntroducerClient(MultiService, object):
    reactor = attr.ib()
    agent = attr.ib()
    url = attr.ib()

    announcements = attr.ib(default=attr.Factory(DataSource))

    def __attrs_post_init__(self):
        super(HTTPIntroducerClient, self).__init__()
        svc = TimerService(
            60,
            self._poll_announcements,
        )
        svc.clock = self.reactor
        svc.setServiceParent(self)

    # compatibility with the IntroducerClient interface
    def subscribe_to(self, service_name, callback):
        self.announcements.subscribe(
            lambda (key_s, ann): (
                callback(key_s, ann)
                if ann.get(u"service-name") == service_name
                else None
            ),
        )

    @inline_callbacks
    def _poll_announcements(self):
        try:
            with start_action(action_type=u"introducer:http-client:poll"):
                announcements = yield get_announcements(self.agent, self.url)
        except Exception as e:
            print(e)
        else:
            for key_s, ann in announcements.items():
                self.announcements.publish((key_s.encode("ascii"), ann))
