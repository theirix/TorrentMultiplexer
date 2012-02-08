# TorrentMultiplexer

Simple tool for multiplexing torrents and magnet links to
seed servers, local torrent client and filesystem.

Torrents are copied by scp to the remote directory specified by mask.
Seed kind is propagated to a mask as a parameter.

Saving magnet link to a file is libtorrent-specific.

## Requirements

GEBEncoding with a stability fix.

## TODO

  * Fight a bug with reopening documents on Lion

  * Send magnet links to servers in one click instead of saving them to file

<!--vim: ft=markdown, expandtab -->

