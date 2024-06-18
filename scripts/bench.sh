#!/usr/bin/bash

USAGE="$0 (go|jvm|native)"

show_usage () {
  echo "Error: $1"
  echo $USAGE
  exit 1
}

finish () {
  echo "Error:"
  echo $1
  echo "Exiting..."
  exit 1
}

# program arguments config:
TIMEOUT=10000 # ms
REPEATE_COUNT=2
COOL_DOWN_TIME=2 # s


# program execution config:

# Go
GO_ROOT="../go"
set_go_vars () {
  CMD="$GO_ROOT/main -timeout=$TIMEOUT -max-connections=$2"
  ROOT="$GO_ROOT"
  TARGET_FILE="$GO_ROOT/results/test-$1-$2-$3.out"
}
prepare_go () {
  HERE=$(pwd)
  cd $GO_ROOT
  
  go build main.go
  if [ $? -ne 0 ]; then
    finish "Failed to build go program"
  fi
  
  cd $HERE
}

# JVM
JVM_ROOT="../gears/jvm"
set_jvm_vars () {
  CMD="java -jar $JVM_ROOT/target/scala-3.3.3/web-crawler-gears-assembly-0.1.0-SNAPSHOT.jar $TIMEOUT $2"
  ROOT="$JVM_ROOT"
  TARGET_FILE="$JVM_ROOT/results/test-$1-$2-$3.out"
}
prepare_jvm () {
  HERE=$(pwd)
  cd "$JVM_ROOT/.."

  sbt rootJVM/assembly
  if [ $? -ne 0 ]; then
    finish "Failed to build JVM program"
  fi
  
  cd $HERE
}

# NATIVE
NATIVE_ROOT="../gears/native"
set_native_vars () {
  CMD="$NATIVE_ROOT/target/scala-3.3.3/web-crawler-gears $1 $TIMEOUT $2"
  ROOT="$NATIVE_ROOT"
  TARGET_FILE="$NATIVE_ROOT/results/test-$1-$2-$3.out"
}
prepare_native () {
  HERE=$(pwd)
  cd "$NATIVE_ROOT/.."
  
  sbt rootNative/run
  if [ $? -ne 0 ]; then
    finish "Failed to build native program"
  fi
  
  cd $HERE
}

if [ $# -ne 1 ]; then
  show_usage "Missing program argument"
fi

NAME=$1
case $NAME in
  go)
    set_vars() { 
      set_go_vars $1 $2 $3 
    }
    prepare() {
      prepare_go
    }
    ;;
  jvm)
    set_vars() { 
      set_jvm_vars $1 $2 $3 
    }
    prepare() {
      prepare_jvm
    }
    ;;
  native)
    set_vars() { 
      set_native_vars $1 $2 $3 
    }
    prepare() {
      prepare_native
    }
    ;;
  *)
    show_usage "Invalid program argument"
    ;;
esac

echo "--------Starting benchmark for $NAME--------"

echo "Setting up vars"
set_vars 0 0 0

echo "Preparing"
prepare

echo "Creating results directory"
TARGET_DIR="$ROOT/results"
TARGET_BACKUP_DIR="$ROOT/prev-results"
if [ -d "$TARGET_DIR" ]; then
  if [ -d "$TARGET_BACKUP_DIR" ]; then
    read -p "Do you want to delete the old data? (y/n): " answer
    if [ "$answer" == "y" ]; then
      rm -rf $TARGET_BACKUP_DIR
    else
      echo "Please store the old data somewhere else and try again."
      exit 1
    fi
    rm -rf $TARGET_BACKUP_DIR
  fi
  mv $TARGET_DIR $TARGET_BACKUP_DIR
fi

mkdir $TARGET_DIR

echo "Running $NAME benchmarks"
for threads in 1 2 4; do
  for connections in 1 10 100 1000; do
    echo "Running $NAME with $threads threads and $connections connections:"
    for ((i=0 ; i<REPEATE_COUNT ; i++)); do
      set_vars $threads $connections $i
      cmd="taskset -c 0-$((threads-1)) $CMD | tee tmp"
      eval $cmd
      if [ $? -ne 0 ]; then
        echo "Benchmark failed for $n threads and $connections connections"
        cat tmp
        rm tmp
        exit 1
      fi
      cp tmp $TARGET_FILE
      rm tmp
      sleep $COOL_DOWN_TIME
    done
  done
done
