#!/usr/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <name>"
  exit 1
fi

NAME=$1
REPEATE_COUNT=2

for threads in 1 2 4; do
  res="name,threads,found\n"
  for connections in 1 10 100 1000; do
    found=0
    for ((i=0 ; i<REPEATE_COUNT ; i++)); do
      current_found=$(cat results/all/test-$threads-$connections-$i.out | grep "found=" | cut -d"=" -f2)
      found=$((found+current_found))
    done
    found=$(echo "scale=0; $found / $REPEATE_COUNT" | bc)
    res="$res$NAME,$connections,$found\n"
  done
  echo -e $res > results/$NAME-$threads.csv
done