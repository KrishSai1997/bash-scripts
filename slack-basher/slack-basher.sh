#!/bin/bash
# slack-basher.sh
# by Chris Holt 2016-05-06

# Purpose:
#  Automated Brute force guess Slack API tokens using slazy
#  https://github.com/humor4fun/slack-basher

##################################
# environment variables
title="slack-basher"
version="1.06"
author="Chris Holt, @humor4fun"
date="2016-05-16"
usage="$title by $author 
	Version: $version 
	Last updated date: $date 
	
Usage: 
	$title [options]
	
	This tool will run multiple iterations of slazy.sh to create benchmark reports. Slasy will query the Slack API web interface looking for valid tokens. Requires a text file containing the Slack API token used to make sure that our testing IP has not yet been blocked to ba named \"token\".

Options:
	-c | --cycles COUNT
	 	Defines the number of iterations to perform testing.
		Default: 100.		
	-b | --benchmark-file FILE
		Text FILE to write the benchmark report to. Data will be appended.
		Default: basher_report.log
	-h | --help
		Displays this help message.
	-m | --max-try COUNT
		Defines the number of tokens to attempt per iteration.
		Default: 100."		
##################################


##################################
# read input from command line
# Use > 0 to consume one or more arguments per pass in the loop (e.g. some arguments don't have a corresponding value to go with it such as in the --default example).
debug_off=true
max_try=100
cycles=100
help=false
benchmark_file="basher_report.log"

while [[ $# > 0 ]]
 do
	key="$1"
	case $key in
		-m|--max-try)
			max_try="$2"
		 	shift
		 ;;
		-c|--cycles)
			cycles="$2"
			shift
		;;
		-b|--benchmark-file)
			benchmark_file="$2"
			shift
		;;
		-h|--help)
			help=true
		;;	
		*) # unknown option
		;;
	esac
	shift # past argument or value
done

if ( $help )
 then
	printf "$usage\n"
	exit 200
fi
##################################


##################################
# core code block
printf "$title v$version by $author\n"
START=$(date +%s)
date_start=`date`

n=0
while [ $n -lt $cycles ]
do
	./slazy.sh --slack-token-file token --max-try $max_try --max-find 1 1>/dev/null
	n=$[n+1]
done

sort -u --output invalid.unique invalid.tokens
END=$(date +%s)
##################################


##################################
# print a report
SEC=$(( $END - $START ))
HOUR=$(( $SEC / 3600 ))
MIN=$(( ( $SEC % 3600 ) / 60 ))
SEC=$(( $SEC % 60 ))
TTC="$HOUR:$MIN:$SEC"
date_end=`date`
total=`wc -l invalid.tokens | cut -f1 -d' '`
unique=`wc -l invalid.unique | cut -f1 -d' '`

REPORT="Execution Report:
	Tokens Tested: $total
	Unique Tokens:  $unique
	Start: $date_start
	End:   $date_end
	TTC: $TTC\n\n"

#print to screen
	printf "$REPORT" 
#print to file
	printf "%s,%s,%s\n" $TTC $total $unique >> $benchmark_file 
##################################

exit 200
