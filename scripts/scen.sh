#!/usr/bin/bash

rm -rf results

export SERVER_BINDING="5-7"

export TIMEOUT=100 # 20000                                                                        # ms
export THREADS_SEQ="1 " # 2 4 8"                                                                # threads
export CONNECTIONS_SEQ="1 " # 16 128 512 600 800 1024 1200 1400 1600 1800 2048 4096 8192 16384" # connections

export REPEATE_COUNT=1 # 5      # s
export COOL_DOWN_TIME=5     # s
export AFTER_SERVER_START=5 # s

export SERVER_CONFIG_PATH="./heavy.json"

echo "Running multi-threaded clients"
for name in go gJvm gNative cJvm gurl; do
  yes | ./bench.sh $name
  if [ $? -ne 0 ]; then
    echo "failed to run the experiment for $name"
  fi
done

echo "Running single-threaded clients"
export THREADS_SEQ="1" # threads
for name in singleThreaded cNative; do
  yes | ./bench.sh $name
  if [ $? -ne 0 ]; then
    echo "failed to run the experiment for $name"
  fi
done

echo "generating the cv"
./genCSV.sh all
echo "gathering gc stats"
./gatherGC.sh

echo "creating notes.txt"
touch ./results/notes.txt
echo "timeout: $TIMEOUT" >> ./results/notes.txt
echo "server config path: $SERVER_CONFIG_PATH" >> ./results/notes.txt
echo "threads: $THREADS_SEQ" >> ./results/notes.txt
echo "connections: $CONNECTIONS_SEQ" >> ./results/notes.txt
echo "repeate count: $REPEATE_COUNT" >> ./results/notes.txt
echo "cool down time: $COOL_DOWN_TIME" >> ./results/notes.txt
echo "after server start: $AFTER_SERVER_START" >> ./results/notes.txt
# CHANGE HERE:
echo "gc is enabled" >> ./results/notes.txt
