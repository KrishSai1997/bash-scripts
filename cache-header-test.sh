#!/bin/bash
# Fetch the top X Alexa sites and crawl them, fetching HEAD only. Then test the results to see if they are using Pragma and Cache-Control headers.
# change the the length of the list by setting a number 1 to 1,000,000 in the first parameter
# ./cache-header-test 10 -> tests the top 10 sites only

sitelist="$dir/sitelist.txt"
listlen=10
dir="cache-header-test"
pcount="$dir/P.txt"
cccount="$dir/CC.txt"
pcccount="$dir/P+CC.txt"
ncount="$dir/xP+CC.txt"
errors="$dir/errors.txt"
timedout="$dir/timedout.txt"
timeout=10
exclude="$dir/exclude.txt"
excluded="$dir/excluded.txt"
rm $exclude $excluded
skip=0

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      printf "\033[0m\ncache-header-test by Chris Holt\nPurpose:\n\tTo test a list of websites for identifying which headers they present.\n\nUsage:\n\tcache-header-test [--output directory] [--list file] [--alexa num] [--exclude file] [--help]\n\t\033[0;34m-o | --output DIRECTORY\033[0m\tThe directory to put output files into. This MUST be the first flag specified. Default to cache-header-test if not specified.\n\t\033[0;34m-l | --list FILE\033[0m\tA file containing the list of websites to be tested. If this parameter is omitted, the Alexa Top 1,000,000 Sites list is used.\n\t\033[0;34m-a | --alexa NUM\033[0m\tThe number of sites from the Alexa Top 1,000,000 to be tested.\n\t\033[0;34m-x | --exclude FILE\033[0m\tA file containing a list of domains to be excluded from testing. This flag and argument can be repeated multiple times.\n\t\033[0;34m-t | --timeout SECONDS\033[0m\tNumber of seconds to allow cURL to execute before forcing a timeout. Default to 10 seconds if not specified.\n\t\033[0;34m-h | --help\033[0m\tPrint this help message.\n\nExamples:\n\tcache-header-test -a 100\t\tTest the Alexa Top 100 Sites\n\tcache-header-test -l mylist.txt\t\tTest the all domains listed in mylist.txt\n\tcache-header-test -a 10000 -x timedout.txt\t Test the Alexa Top 10,000 sites, excluding those in the timedout.txt file which was a byproduct of a previous execution.\n\n"
      exit 0
      ;;

    -o|--output)
      dir="$2"
      mkdir -p $dir
      shift
      ;;

    -l|--list)
      sitelist="$2"
      listlen=$(wc -l < "$sitelist")
      mkdir -p $dir
      shift
      ;;

    -a|--alexa)
      sitelist="$dir/sitelist.txt"
      let "listlen = $2 % 1000000"
      mkdir -p $dir
      #Get Alexa top 1000 sites
      #source: https://gist.github.com/evilpacket/3628941
      wget -q http://s3.amazonaws.com/alexa-static/top-1m.csv.zip;unzip top-1m.csv.zip
      awk -F ',' '{print $2}' top-1m.csv | head -$((listlen)) > $sitelist
      rm top-1m.csv*
      shift
      ;;

    -x|--exclude)
      cat $2 >> "$excluded"
      shift
      ;;

    -t|--timeout)
      timeout=$2
      shift
      ;;
  esac
  shift # past argument or value
done

#clear old dataset
files=( $pcount $cccount $pcccount $ncount $errors )
for i in "${files[@]}"
do
  test -e $i && rm $i
  touch $i
done
sort -u "$excluded" > "$exclude"

#crawl the site list
while read site; do
  file="$dir/$site.head"
  res=0

  if [ $(cat "$exclude" | grep -i -c "$site" ) -eq 0 ]; then
    #check if we have the site headers in the local cache, if not get it.
    if [ ! -e "$file" ]; then
     $(curl --head "$site" -o "$file" -m $((timeout)) -s -L)
     res=$?
    fi

    #test if curl reported an error
    if [ $((res)) -gt 0 ]; then
      #Couldn't resolve host(6), empty reply from server(52), Failed to Connect(7), Operation Timeout(28), unsupported protocol(1) -> this occurs when the site headers were already cached
      #printf "\n\033[0;31m%s\033[0m failed. Curl(%s)\n" "$site" "$res"
      printf "\033[0;31m%s\033[0m" "$res"
      printf "%s\n" "$site" >> "$errors"
      skip=$((skip + 1))
      if [ $((res)) -eq 28 ]; then
        #store a separate list of sites that timed out, these might be re-tested
        printf "%s\n" "$site" >> "$timedout"
      fi
    elif [ -e "$file" ]; then
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
      printf "."
    fi
  else
    printf "\033[0;35mx\033[0m"
    skip=$((skip + 1))
  fi
done <"$sitelist"

# Print results table
printf "\n\nResults:\n -----------------------\n"
printf "| %s\t \033[0;36mTotal Tested\033[0m\t|\n" $((listlen - skip))
printf "| %s\t Pragma & C-C\t|\n" $(wc -l < "$pcccount")
printf "| %s\t Pragma Only\t|\n" $(wc -l < "$pcount")
printf "| %s\t C-C Only\t|\n" $(wc -l < "$cccount")
printf "| %s\t Neither\t|\n" $(wc -l < "$ncount")
printf "|  .......... .........\t|\n"
printf "| %s\t \033[0;36mSkipped\033[0m\t|\n" $((skip))
printf "| %s\t \033[0;31merror\033[0m\t\t|\n" $(wc -l < "$errors")
printf "| %s\t \033[0;35mexcluded\033[0m\t|\n" $(wc -l < "$exclude")
printf " -----------------------\n"

errors=$(wc -l < $errors)
exit $((listlen - errors))
