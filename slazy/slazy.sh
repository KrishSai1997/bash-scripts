#!/bin/bash
# slazy.sh
# by Chris Holt 2016-05-05

# Purpose:
#  Brute force guess Slack API tokens
#  https://github.com/humor4fun/slazy


##################################
# print a report
SEC=$(( $END - $START ))
HOUR=$(( $SEC / 3600 ))
MIN=$(( ( $SEC % 3600 ) / 60 ))
SEC=$(( $SEC % 60 ))
date_end=`date`
REPORT="Execution Report:
	Tokens Tested: $count_tried
	Valid Tokens:  $count_found
	Start: $date_start
	End:   $date_end
	TTC: $HOUR:$MIN:$SEC\n\n"

printf "$REPORT"
echo -e "$REPORT" >> $benchmark_file
##################################

exit 200
