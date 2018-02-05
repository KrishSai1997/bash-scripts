# ytdler
Given a list of URLs or Playlists, this script will repeatedly trigger `youtube-dl` until each item in the list successfully completes. This might cause trouble if an item in a playlist is not able to be downloaded. The tool relies on `youtube-dl`'s reliability to correctly return an exit code of 0.

## Installation
1. Save ytdler.sh to a file
2. `chmod +x ytdler.sh`
3. `./ytdler.sh --setup`

## Usage


Default `./ytdler.sh -i input.list`

## Options
```
-i | --input-list FILE
	File that includes the list of URLs to download.
	Default: ~/ytdler/todo.list
-c | --completed-list FILE
  File that will be written to when a URL is completed downloading.
  Default: ~/ytdler/complete.list
-o | --output FOLDER
  Folder that downloads will be stored in.
  Default: ~/ytdler/dl
-s | --setup
  Install required tools and configure youtube-dl to execute when called from command line. Performs a database update.
-h | --help
  Prints this help message.
```

## Sample Input Files
input.list:
```
https://www.youtube.com/playlist?list=PLwP_SiAcdui0KVebT0mU9Apz359a4ubsC
https://www.youtube.com/watch?v=vVhCtv55E9g&list=PL48ED3A2D823691E7
```
## Notes
This script was written and tested on a fresh installation of Debian 9.
```
user@ytdl:~$ uname -a
Linux ytdl 4.9.0.4-amd64 #1 SMP Debian 4.9.65-3+deb9u1 (2017-12-23) x86_64 GNU/Linux
```
