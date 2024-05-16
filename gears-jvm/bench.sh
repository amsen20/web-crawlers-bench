#!/usr/bin/bash

TIMEOUT=10000 # ms
REPEATE_COUNT=2
NAME="gearsJVM"
COOL_DOWN_TIME=5 # s

if [ -d "results" ]; then
  rm -rf results
fi
mkdir results
mkdir results/all

for connections in 1 10 100 1000; do
  res="name,threads,found\n"
  for threads in 1 2 4; do
    found=0
    for ((i=0 ; i<REPEATE_COUNT ; i++)); do
      cmd="taskset -c 0-$((threads-1)) java -jar ./target/scala-3.3.3/web-crawler-gears-jvm-assembly-0.1.0-SNAPSHOT.jar $TIMEOUT $connections | tee tmp"
      eval $cmd
      if [ $? -ne 0 ]; then
        echo "Benchmark failed for $n threads and $connections connections"
        cat tmp
        rm tmp
        exit 1
      fi
      cp tmp results/all/test-$connections-$threads-$i.out
      current_found=$(cat tmp | grep "found=" | cut -d"=" -f2)
      found=$((found+current_found))
      rm tmp
      
      sleep $COOL_DOWN_TIME
    done
    found=$(echo "scale=0; $found / $REPEATE_COUNT" | bc)
    res="$res$NAME,$threads,$found\n"
  done
  echo -e $res > results/$NAME-$connections.csv
done

