#!/bin/bash

# s3get.bash
# by Chris Holt 2017/01/24

# Input a domain name for an s3 bucket and the script will scrape the ListBucketResults.xml file for contents, then fetch all the contents.

HOST=$1
OUTFILE="ListBucketResult.xml"
FILES="FileURLs.list"
LOGD="s3get-log"
LOGW="$LOGD/wget.log"

wget --output-document=$OUTFILE $HOST
sed "s/><\//>\\n<\//g" $OUTFILE | sed "s/></>\\n</g" | grep Key | sed 's/<\/Key>//g' | sed "s/<Key>/http:\/\/$HOST\//g" | sed 's/\s/\%20/g' | sed '/<MaxKeys>/d' > $FILES

mkdir $LOGD

while read -r LINE; do 
    wget --force-directories $LINE
#echo $LINE
done < "$FILES"

mv $OUTFILE $LOGD
mv $FILES $LOGD
mv $LOGD $HOST
