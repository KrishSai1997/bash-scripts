#!/bin/bash
# dice.sh
# by Chris Holt 2016-09-8

# Input a wordlist, randomly sort it, then index the lines to be used for diceware (7 dice). Requires at least 279,936 words.

input=$1
if [[ -z $1 ]]; then
	printf "No word list suppled. Quitting.\n"
	printf "Usage \"dice.sh words.list\" add -silent to silence the per-line output.\n"
	exit -1
fi

printf "Sorting..."
cat $input | sort -R > tmp.t
printf "done.\n"
	

printf "Labeling lines..."
line=1
output="7dice.list"

for a in `seq 1 6`;
do
	for b in `seq 1 6 `;
	do
		for c in `seq 1 6 `;
		do
			for d in `seq 1 6 `;
			do
				for e in `seq 1 6 `;
				do
					for f in `seq 1 6 `;
					do
						for g in `seq 1 6 `;
						do
							text=`sed $line!d tmp.t`
							t=`printf "%s%s%s%s%s%s%s\t%s" "$a" "$b" "$c" "$d" "$e" "$f" "$g" "$text"`
							if [[ -z $2 ]]; then
								echo "$t"
							fi
							printf "%s" "$t" >> $output
							line=$((line + 1))
						done
					done
				done
			done
		done
	done
done
printf "done.\n:) find the file \"$output\""

rm tmp.t
exit 0

							
							

	
