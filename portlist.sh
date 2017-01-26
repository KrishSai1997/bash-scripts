#!/bin/bash
# portlist.sh
# by Chris Holt 2016-03-31

# Purpose:
# Prints a space delimited list of all ports in the range specified by

counter=80
step=100
while [ $counter -lt 65536 ]; do
	printf "$counter " | tee -a ports.log
	let counter=counter+step
done
