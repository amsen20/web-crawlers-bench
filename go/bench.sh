#!/usr/bin/bash

TIMEOUT=10000 # ms
REPEATE_COUNT=2
COOL_DOWN_TIME=5 # s
NAME="go"
CMD="./main"

if [ -d "results" ]; then
  rm -rf results
fi
mkdir results
mkdir results/all

go build main.go

for threads in 1 2 4; do
  for connections in 1 10 100 1000; do
    echo "Running $NAME with $threads threads and $connections connections:"
    found=0
    for ((i=0 ; i<REPEATE_COUNT ; i++)); do
      cmd="taskset -c 0-$((threads-1)) $CMD -timeout=$TIMEOUT -max-connections=$connections | tee tmp"
      eval $cmd
      if [ $? -ne 0 ]; then
        echo "Benchmark failed for $n threads and $connections connections"
        cat tmp
        rm tmp
        exit 1
      fi
      cp tmp results/all/test-$threads-$connections-$i.out
      rm tmp
      sleep $COOL_DOWN_TIME
    done
  done
done
