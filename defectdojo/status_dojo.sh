#!/bin/bash
# 2017-03-01 by Chris Holt (@humor4fun)
# Heartbeat tests for the Dojo services
#
# Setup this script by running `echo your.domain.com > domain` in the same directory
# Call this script using ./status_dojo.sh

check_site () 
{
# $1 should be the test id
# $2 should be the URL
# $3 should be the search term
	NC='\033[0m' #no color
	RED='\033[1;31m' #red
	GREEN='\033[0;32m' #green	

	printf "Test %s: " $1	
	if (( `curl "$2" -s -S --head 2>&1 | grep -c "$3"` > 0 ))
	 then
		printf "${GREEN}OK${NC}\n"
		return 1 
	else
		printf "${RED}Error\n!!\tRequest on: %s\n!!\tExpected Result: %s\n~~\tThoughts: %s\n${NC}" "$2" "$3" "$4"
		return 0
	fi
}

DOMAIN=`cat domain`

# is django responding?
check_site "1.1" "http://127.0.0.1:8000" "HTTP/1.0 302" "Django is not running"
check_site "1.2" "http://127.0.0.1:8000/login?next=/" "HTTP/1.0 200" "Django is not running"
check_site "1.3" "https://127.0.0.1:8000" "curl: (35)" "HTTPS is ON for Django...shouldn't be"
check_site "1.4" "https://127.0.0.1:8000/login?next=/" "curl: (35)" "HTTPS is ON for Django...shouldn't be"

check_site "2.1" "http://localhost:8000" "HTTP/1.0 302" "localhost does not resolve"
check_site "2.2" "http://localhost:8000/login?next=/" "HTTP/1.0 200" "localhost does not resolve"
check_site "2.3" "https://localhost:8000" "curl: (35)" "HTTPS is ON for Django...shouldn't be"
check_site "2.4" "https://localhost:8000/login?next=/" "curl: (35)" "HTTPS is ON for Django...shouldn't be"

# is nginx responding?
check_site "3.1" "http://127.0.0.1" "HTTP/1.1 301" "nginx not responding with Django pages"
check_site "3.2" "http://127.0.0.1/login?next=/" "HTTP/1.1 301" "nginx not responding with Django pages"
check_site "3.3" "https://127.0.0.1" "curl: (51)" "SSL Subject name matches the target hostname...it shouldn't"
check_site "3.4" "https://127.0.0.1/login?next=/" "curl: (51)" "SSL Subject name matches the target hostname...it shouldn't"

check_site "4.1" "http://"$DOMAIN"" "HTTP/1.1 301" "domain name not configured or DNS not pointing to this server"
check_site "4.2" "http://"$DOMAIN"?next=/" "HTTP/1.1 301" "domain name not configured or DNS not pointing to this server"
check_site "4.3" "https://"$DOMAIN"" "HTTP/1.1 302" "domain name not configured or DNS not pointing to this server"
check_site "4.4" "https://"$DOMAIN"/login?next=/" "HTTP/1.1 200" "domain name not configured or DNS not pointing to this server"
