#!/bin/bash

#pull all PDFs off the MetMuseum resources folder using a google search

for (( i=0; i <=1110; i+=10 ))
do
  curl --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36" --url  "https://www.google.com/search?q=site:resources.metmuseum.org/resources/metpublications/pdf&start=$i" | tr \< \\n | tr \> \\n | tr = \\n | tr \" \\n | grep http://resources >> booklist.txt
done

sort -u booklist.txt > books.list

while read LIST
do
  wget $LIST
done < booklist.txt

#cleanup
#rm booklist.txt books.list
