#!/bin/bash

# Download all videos/playlists specified in the local ytdl.list file. Completed playlists will be moved to 'complete.list'

#TODO
# move the two lists into input parameters
# add help printout

trap control_c INT # catch ctrl-c command
control_c()
{
	printf "\n\e[7m****USER INTERRUPT****\n\e[0m"
	exit $?
}

message()
{
	printf "\n\e[32m\e[1m[[ytdler]]\e[21m \e[34m%s\n\e[0m" "$1"
}

install()
{
	message "Installing dependancies if they do not exist."
	sudo apt-get install curl ffmpeg mpv mplayer axel

	message "Installing youtube-dl from source."
	sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
	sudo chmod a+rx /usr/local/bin/youtube-dl
	sudo ln -s /usr/local/bin/youtube-dl /usr/bin/youtube-dl

	message "Updating youtube-dl database."
	youtube-dl -U
	exit 0
}

folder="~/ytdler/dl"
playlist="~/ytdler/todo.list"
complete="~/ytdler/complete.list"
setup=0
ex=1

while [[ $# > 0 ]]
do
	key="$1"
	case $key in
		-i|--input-list)
			playlist="$2"
		 	shift
		 ;;
		-c|--completed-list)
			completed="$2"
			shift
		;;
		-o|--output)
			completed="$2"
			shift
		;;
		-s|--setup)
			install
		;;
		-h|--help)
			printf "\nytdler is written by Chris Holt (@humor4fun)\nThis program takes in a list of youtube-dl supported URLs and will download all of them.\n\nUsage:\n\t-i | --input-list FILE \n\t\t\tFile that includes the list of URLs to download.\n\t-c | --completed-list FILE\n\t\t\tFile that will be written to when a URL is completed downloading.\n\t\t\tDefault: ~/ytdler/complete.list\n\t-o | --output FOLDER\n\t\t\tFolder that downloads will be stored in.\n\t\t\tDefault: ~/ytdler/dl\n\t-s | --setup\n\t\t\tInstall required tools and configure youtube-dl to execute when called from command line. Performs a database update.\n\t-h | --help\n\t\t\tPrints this help message."
			exit 0
		;;
	esac
		shift # past argument or value
done

list=`head -n 1 "$playlist"`
message "Starting Download of: $list"

while [ "$ex" -ne 0 ]
do
	youtube-dl --embed-subs --add-metadata --all-subs -i --external-downloader axel --external-downloader-args "-a -k -n 10" -o "$folder/%(playlist)s/%(title)s.%(ext)s" "$list"
	ex="$?"

	if [ "$ex" -ne 0 ]
	then
		message "Download failed. Trying again."
	fi
done

printf "%s\n" >> "$complete" #write the playlist link to the completed list
sed -i '/"$list"/d' "$playlist" #remove the playlist link from the todo list
message "Item Complete"


if [ `wc -l < "$playlist"` -eq 0 ] #file is empty
	message "Finished downloading all entries in $playlist"
	exit 0
else
	message "Program reloading for next item."
	ytdler -i $playlist -o $folder -c $complete #execute again because there is another line
fi
