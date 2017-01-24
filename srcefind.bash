#!/bin/bash
# by Chris Holt
# 2016-12-20

grep -r -i -c -f /path/to/words.list /folder/to/search/ | grep -v ':0$' | uniq | sed -r 's/([^:]*)(:[0-9]*$)/\2 \1/gm' | sed -r 's/://m' | sort -nr
