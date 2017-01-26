#!/bin/bash
# freecycle-buzz.sh
# by Chris Holt 2016-08-22

# Purpose:
#  Get the titles of all posts on FreeCycle.org for specified cities. Also separates out the posts from TODAY in a fresh section at the top

cities=("FairfaxCityVA" "HaymarketGainesvilleVA" "LeesburgVA" "McLeanViennaVA" "RestonVA" "WarrentonVA" "ChantillyCentrevilleVA")
touch res.txt new.txt

for city in "${cities[@]}"
do

	total=`curl -s "https://groups.freecycle.org/group/$city/posts/offer?page=1&resultsperpage=100&include_offers=on&include_wanteds=off" | grep -E "<p> Showing .* results.<br />" | cut -d' ' -f11`
	remain=0
	page=0
	printf "$city, Total:$total, Pages-"
	printf "<br />\n<h2>%s, %s</h2>\n<br \>\n" "$city" "$total" >> res.txt
	printf "<br />\n<h2>%s %s</h2>\n<br \>\n" "$city" >> new.txt
	while [[ "$remain" != "" && "$remain" != "$total" || "$remain" > "$total" ]]
	do
		page=$[page + 1]
		printf "$page.."
		curl -s "https://groups.freecycle.org/group/$city/posts/offer?page=$page&resultsperpage=100&include_offers=on&include_wanteds=off" | grep -E "<a href='https://groups.freecycle.org/group/$city/posts/.* <br />" | cut -d'<' -f1-4 >> res.txt
		today=`date +%a-%b-%d | tr '-' ' '`
		curl -s "https://groups.freecycle.org/group/$city/posts/offer?page=$page&resultsperpage=100&include_offers=on&include_wanteds=off" | grep -E "Mon Aug 22" -A 4 | grep -E "<a href=.* <br />" | cut -d'<' -f1-4 >> new.txt

		
		remain=`curl -s "https://groups.freecycle.org/group/$city/posts/offer?page=$page&resultsperpage=100&include_offers=on&include_wanteds=off" | grep -E "<p> Showing .* results.<br />" | cut -d' ' -f9`
	done
	printf "\n"
done

sed 's/ < br \/> /\n<br \/>\n/g' res.txt >res.html
sed 's/ < br \/> /\n<br \/>\n/g' new.txt >new.html
results=`cat res.html`
new=`cat new.html`
date=`date +%Y-%m-%d`
printf "<html>\n\t<head>\n\t\t<title>FreeCycle Postings</title>\n\t</head>\n\t<body>\n\t\t<h1>FreeCycle Postings</h1>\n\t\t<h3>Active Date: %s</h3> <br />\n\t\t<br/>\n\t\t<h1>Newly Posted Today</h1>\n\t\t%s\n\t\t<h1>All Results</h1>\n\t\t%s\n\t</body>\n</html>\n" "$date" "$new" "$results" > FreeCycle-$date.html
rm res.txt res.html new.txt new.html

