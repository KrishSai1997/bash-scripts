#!/bin/bash
# cURLers.sh
# by Chris Holt 2016-01-13

# Purpose:
#  Use cURL to load a list of URLs into Burp. Issues a GET request to each one in sequence. Shows line numbers for stop/restart purposes
# Usage: 
##   $> ./curlers.sh input_list proxy_ip port line_num
# line_num is an optional parameter

# Some extra notes that may be helpful upon revisiting this script...
# If URL list does not contain domains, use this:
##   $> awk '{print "http://domain.com" $0}' input > output
# Join multiple files:
##   $> cat file1 file2 > output
# Run the script and push output to console and log file
##  $> ./curlers.sh input ip port 2>&1 | tee log

list=$1
proxy=$2
port=$3
line=$4

echo "Starting from line $line"
{
	for ((i=$line;i--;)) ;do
		read
		done
	while read url ;do
		echo "Current line: $line"
		command="curl -# --proxy $proxy:$port $url"
		echo `$command`
		line=$((line +1));
		done
} < $list
echo "Completed Task."


