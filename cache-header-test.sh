#!/bin/bash
# Fetch the top X Alexa sites and crawl them, fetching HEAD only. Then test the results to see if they are using Pragma and Cache-Control headers.
# change the the length of the list by setting a number 1 to 1,000,000 in the first parameter
# ./cache-header-test 10 -> tests the top 10 sites only

dir="cache-header-test"
sitelist="$dir/sitelist.txt"
pcount="$dir/P.txt"
cccount="$dir/CC.txt"
pcccount="$dir/P+CC.txt"
ncount="$dir/xP+CC.txt"
alexa=$1
timeout=10

#clear old dataset
#rm -r $dir -> will delete all the fetched head data as well, but is quicker.
mkdir -p $dir
files=( $pcount $cccount $pcccount $ncount )
for i in "${files[@]}"
do
  test -e $i && rm $i
  touch $i
done

#Get Alexa top 1000 sites
#source: https://gist.github.com/evilpacket/3628941
wget -q http://s3.amazonaws.com/alexa-static/top-1m.csv.zip;unzip top-1m.csv.zip
awk -F ',' '{print $2}' top-1m.csv | head -$((alexa)) > $sitelist
rm top-1m.csv*

#crawl the site list
while read site; do
  file="$dir/$site.head"

  #check if we've already fetch this site, if not get it.
  test ! -e "$file" && $(curl --head "$site" -o "$file" -m $((timeout)) -L)

  if [ $(cat "$file" | grep -i -c "Pragma") -gt 0 ]; then
    if [ $(cat "$file" | grep -i -c "Cache-Control") -gt 0 ]; then
      printf "%s\n" "$site" >> "$pcccount"
    else
      printf "%s\n" "$site" >> "$pcount"
    fi
  else
    if [ $(cat "$file" | grep -i -c "Cache-Control") -gt 0 ]; then
      printf "%s\n" "$site" >> "$cccount"
    else
      printf "%s\n" "$site" >> "$ncount"
    fi
  fi
done <"$sitelist"

# Print results table
printf "Results with %ss Timout\n -----------------------\n" $(($timeout))
printf "| %s\t Pragma Only\t|\n" $(wc -l < "$pcount")
printf "| %s\t C-C Only\t|\n" $(wc -l < "$cccount")
printf "| %s\t Pragma & C-C\t|\n" $(wc -l < "$pcccount")
printf "| %s\t Neither\t|\n" $(wc -l < "$ncount")
printf " -----------------------\n"
