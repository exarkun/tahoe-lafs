
Call graph::

  allmydata.client._Client.__init__
  -> allmydata.client._Client.init_magic_folder
    -> magic_folder.MagicFolder.from_config
      -> magic_folder.MagicFolder.Uploader.__init__
      -> magic_folder.MagicFolder.Downloader.__init__
    -> magic_folder.MagicFolder.setServiceParent
      -> magic_folder.MagicFolder.startService
        -> magic_folder.Uploader.start_monitoring
          -> magic_folder.Uploader._add_watch
            -> INotify.watch
          -> INotify.startReading
            -> magic_folder.MagicFolder._notify
              -> magic_folder.MagicFolder._real_notify
                -> magic_folder.MagicFolder._add_pending
    -> magic_folder.MagicFolder.ready
      -> magic_folder.Uploader.start_uploading
        -> magic_folder.Uploader._full_scan
	  -> magic_folder.Uploader._scan
	-> magic_folder.Uploader._begin_processing
	  -> magic_folder.Uploader._processing_iteration
	    -> magic_folder.Uploader._perform_scan
	    -> magic_folder.Uploader._process_deque
	      -> magic_folder.Uploader._process
	        -> add_file
      -> magic_folder.Downloader.start_downloading
        -> magic_folder.Downloader._scan_remote_collective
	-> magic_folder.Downloader._begin_processing
	  -> magic_folder.Downloader._processing_iteration
	    -> magic_folder.Downloader._perform_scan
	      -> magic_folder.Downloader.scan_remote_collective
	    -> magic_folder.Downloader._process_deque
	      -> magic_folder.Downloader._process
	        -> download_best_version

State::

  QueueMixin
    _deque :: [IQueuedItem]

    _in_progress :: [IQueuedItem]

    _process_history :: [IQueuedItem]


  QueueMixin
    _process_deque
      Moves items out of _deque and into _in_progress
      Adds them to _process_history before _process
      Invariants:
        len(_deque) == 0
	len(_in_progress) == 0
	len(_process_history) <= 20


  Uploader is-a QueueMixin
    _pending :: set


  Uploader
    start_uploading
      Adds all database paths to _pending

    _scan
      Adds all local paths to _pending

    _process
      Removes item from _pending

  Downloader



Notes:

#. ``is_upload_pending`` is unused.
   This was previously used to implement download-while-upload-pending conflict detection.
   The use was removed in

   * ``affb80e39e33417abc2935c2da4e577173913f91`` (commit)
   * ``c9e00a988ae90ad5e63897607c70404974d370b2`` (merge commit)
   * https://github.com/tahoe-lafs/tahoe-lafs/pull/475 (PR)

   maybe incorrectly.
