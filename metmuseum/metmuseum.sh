#!/bin/bash

#Credit for this script goes to Reddit user 'ting_bu_dong'

for i in {1..42}
do
  curl "https://www.metmuseum.org/art/metpublications/titles-with-full-text-online?searchtype=F&pg=$i" >> temp.txt
done

cat temp.txt | grep moreHyperLink | grep -o -P '(?<=/art/metpublications/).*(?=\?)' >> booklist.txt

while read LIST
do
  wget http://resources.metmuseum.org/resources/metpublications/pdf/$LIST.pdf
done < booklist.txt
