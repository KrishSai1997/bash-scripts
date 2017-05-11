#!/bin/bash
# 2017-05-11 Chris Holt
# Usage: users-in-channel.sh TOKEN CHANNEL

# This script takes in a Slack API token and a Channel name (token must be able to access it) and will list out the friendly names of all users that are subscribed to the channel
# Tested on: Linux kali 4.9.0-kali3-amd64 #1 SMP Debian 4.9.18-1kali1 (2017-04-04) x86_64 GNU/Linux

token=$1
channel=$2
id=`curl -s https://slack.com/api/channels.list?token="$token" | tr , '\n' | grep "\"name\":\"$channel\"" -B 1 | grep id | cut -c 8- | sed 's/"//g'`

userids=`curl -s "https://slack.com/api/channels.info?token=$token&channel=$id&pretty=1" | sed '1,/members/d' | sed '/topic/,$d' | sed 's/]//g' | sed 's/,//g' | sed 's/"//g' | sed 's/ //g'`

users=`curl -s "https://slack.com/api/users.list?token=$token&pretty=1"`

for name in $userids
do
 echo "$users" | grep "\"id\": \"$name\"," -A 3 | grep "\"name\":" | sed 's/"//g' | sed 's/,//g' | sed 's/ //g' | sed 's/name://g'
done

