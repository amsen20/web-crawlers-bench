#!/usr/bin/bash

USAGE="$0 (go|gJvm|gNative|cJvm|cNative|singleThreaded|gurl|all)"

show_usage() {
  echo "Error: $1"
  echo $USAGE
  exit 1
}

finish() {
  echo "Error:"
  echo $1
  echo "Exiting..."
  exit 1
}

# program arguments config:
if [ -z "$TIMEOUT" ]; then
  echo "no TIMEOUT variable found"
  exit 1
fi
echo "TIMEOUT=$TIMEOUT"

if [ -z "$THREADS_SEQ" ]; then
  echo "no THREADS_SEQ variable found"
  exit 1
fi
echo "THREADS_SEQ=$THREADS_SEQ"

if [ -z "$CONNECTIONS_SEQ" ]; then
  echo "no CONNECTIONS_SEQ variable found"
  exit 1
fi
echo "CONNECTIONS_SEQ=$CONNECTIONS_SEQ"

if [ -z "$REPEATE_COUNT" ]; then
  echo "no REPEATE_COUNT variable found"
  exit 1
fi
echo "REPEATE_COUNT=$REPEATE_COUNT"

if [ -z "$COOL_DOWN_TIME" ]; then
  echo "no COOL_DOWN_TIME variable found"
  exit 1
fi
echo "COOL_DOWN_TIME=$COOL_DOWN_TIME"

if [ -z "$COOL_DOWN_TIME" ]; then
  echo "no AFTER_SERVER_START variable found"
  exit 1
fi
echo "AFTER_SERVER_START=$AFTER_SERVER_START"

# program execution config:

# Go
GO_ROOT="../go"
set_go_vars() {
  CMD="$GO_ROOT/main -timeout=$TIMEOUT -max-connections=$2"
  ROOT="$GO_ROOT"
  TARGET_FILE="$GO_ROOT/results/test-$1-$2-$3.out"
}
prepare_go() {
  HERE=$(pwd)
  cd $GO_ROOT

  go build main.go
  if [ $? -ne 0 ]; then
    finish "Failed to build go program"
  fi

  cd $HERE
}

# TODO move this functions to script folders in each project
# Gears JVM
GEARS_JVM_ROOT="../gears/jvm"
set_gears_jvm_vars() {
  CMD="java -jar $GEARS_JVM_ROOT/target/scala-3.3.3/web-crawler-gears-assembly-0.1.0-SNAPSHOT.jar $TIMEOUT $2"
  ROOT="$GEARS_JVM_ROOT"
  TARGET_FILE="$GEARS_JVM_ROOT/results/test-$1-$2-$3.out"
  export GC_STATS_FILE="$GEARS_JVM_ROOT/results/gc-stats-$1-$2-$3.csv"
}
prepare_gears_jvm() {
  HERE=$(pwd)
  cd "$GEARS_JVM_ROOT/.."

  sbt rootJVM/assembly
  if [ $? -ne 0 ]; then
    finish "Failed to build JVM program"
  fi

  cd $HERE
}

# Gears NATIVE
NATIVE_ROOT="../gears/native"
set_gears_native_vars() {
  CMD="$NATIVE_ROOT/target/scala-3.3.3/web-crawler-gears $1 $TIMEOUT $2"
  ROOT="$NATIVE_ROOT"
  TARGET_FILE="$NATIVE_ROOT/results/test-$1-$2-$3.out"
  export GC_STATS_FILE="$NATIVE_ROOT/results/gc-stats-$1-$2-$3.csv"
}
prepare_gears_native() {
  HERE=$(pwd)
  cd "$NATIVE_ROOT/.."

  sbt rootNative/nativeLink
  if [ $? -ne 0 ]; then
    finish "Failed to build native program"
  fi

  cd $HERE
}

# Cats effect JVM
CATS_JVM_ROOT="../cats/jvm"
set_cats_jvm_vars() {
  CMD="java -jar $CATS_JVM_ROOT/target/scala-3.3.3/web-crawler-cats-effect-assembly-0.1.0-SNAPSHOT.jar $TIMEOUT $2"
  ROOT="$CATS_JVM_ROOT"
  TARGET_FILE="$CATS_JVM_ROOT/results/test-$1-$2-$3.out"
  export GC_STATS_FILE="$CATS_JVM_ROOT/results/gc-stats-$1-$2-$3.csv"
}
prepare_cats_jvm() {
  HERE=$(pwd)
  cd "$CATS_JVM_ROOT/.."

  sbt rootJVM/assembly
  if [ $? -ne 0 ]; then
    finish "Failed to build JVM program"
  fi

  cd $HERE
}

# Cats effect NATIVE
CATS_NATIVE_ROOT="../cats/native"
set_cats_native_vars() {
  CMD="$CATS_NATIVE_ROOT/target/scala-3.3.3/web-crawler-cats-effect-out $TIMEOUT $2"
  ROOT="$CATS_NATIVE_ROOT"
  TARGET_FILE="$CATS_NATIVE_ROOT/results/test-$1-$2-$3.out"
  export GC_STATS_FILE="$CATS_NATIVE_ROOT/results/gc-stats-$1-$2-$3.csv"
}
prepare_cats_native() {
  HERE=$(pwd)
  cd "$CATS_NATIVE_ROOT/.."

  sbt rootNative/nativeLink
  if [ $? -ne 0 ]; then
    finish "Failed to build native program"
  fi

  cd $HERE
}

if [ $# -ne 1 ]; then
  show_usage "Missing program argument"
fi

# Single threaded
SINGE_THREADED_ROOT="../single-threaded"
set_single_threaded_vars() {
  CMD="$SINGE_THREADED_ROOT/target/scala-3.3.3/crawler $TIMEOUT $2"
  ROOT="$SINGE_THREADED_ROOT"
  TARGET_FILE="$SINGE_THREADED_ROOT/results/test-$1-$2-$3.out"
  export GC_STATS_FILE="$SINGE_THREADED_ROOT/results/gc-stats-$1-$2-$3.csv"
}
prepare_single_threaded() {
  HERE=$(pwd)
  cd "$SINGE_THREADED_ROOT"

  echo $(pwd)
  sbt nativeLink
  if [ $? -ne 0 ]; then
    finish "Failed to build single threaded native program"
  fi

  cd $HERE
}

# gurl
GURL_ROOT="../gurl/native"
set_gurl_vars() {
  CMD="$GURL_ROOT/target/scala-3.3.3/web-crawler-gears $1 $TIMEOUT $2"
  ROOT="$GURL_ROOT"
  TARGET_FILE="$GURL_ROOT/results/test-$1-$2-$3.out"
  export GC_STATS_FILE="$GURL_ROOT/results/gc-stats-$1-$2-$3.csv"
}
prepare_gurl() {
  HERE=$(pwd)
  cd "$GURL_ROOT/.."

  sbt rootNative/nativeLink
  if [ $? -ne 0 ]; then
    finish "Failed to build native program"
  fi

  cd $HERE
}

# Server
SERVER_ROOT="../server"
prepare_server() {
  HERE=$(pwd)
  cd "$SERVER_ROOT"

  echo "Killing servers"
  killall main

  sleep $COOL_DOWN_TIME

  echo "Building server"
  go build main.go

  cd $HERE
}

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
gJvm)
  set_vars() {
    set_gears_jvm_vars $1 $2 $3
  }
  prepare() {
    prepare_gears_jvm
  }
  ;;
gNative)
  set_vars() {
    set_gears_native_vars $1 $2 $3
  }
  prepare() {
    prepare_gears_native
  }
  ;;
cJvm)
  set_vars() {
    set_cats_jvm_vars $1 $2 $3
  }
  prepare() {
    prepare_cats_jvm
  }
  ;;
cNative)
  set_vars() {
    set_cats_native_vars $1 $2 $3
  }
  prepare() {
    prepare_cats_native
  }
  ;;
singleThreaded)
  set_vars() {
    set_single_threaded_vars $1 $2 $3
  }
  prepare() {
    prepare_single_threaded
  }
  ;;
gurl)
  set_vars() {
    set_gurl_vars $1 $2 $3
  }
  prepare() {
    prepare_gurl
  }
  ;;
all)
  echo "Running all benchmarks"
  for name in go gJvm gNative cJvm cNative singleThreaded gurl; do
    $0 $name
    if [ $? -ne 0 ]; then
      finish "failed to run the experiment for $name"
    fi
  done
  exit 0
  ;;
*)
  show_usage "Invalid program argument"
  ;;
esac

echo "--------Starting benchmark for $NAME--------"

echo "Preparing server"
prepare_server

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
for threads in $THREADS_SEQ; do
  for connections in $CONNECTIONS_SEQ; do
    echo "Running $NAME with $threads threads and $connections connections:"
    for ((i = 0; i < REPEATE_COUNT; i++)); do

      echo "starting server..."

      ./server.sh &
      server_pid=$!

      sleep $AFTER_SERVER_START # server startup time

      set_vars $threads $connections $i
      cmd="taskset -c 0-$((threads - 1)) /usr/bin/time -f "memoryUsage=%M" $CMD 2>&1 | tee tmp"
      start_time=$(date +%s%3N)
      eval $cmd
      exit_code=$?
      end_time=$(date +%s%3N)

      echo "killing server..."
      killall main

      # if [ exit_code -ne 0 ]; then
      #   echo "$name's benchmark failed for $n threads and $connections connections"
      #   cat tmp
      #   rm tmp

      #   echo "cleaning..."
      #   killall java
      #   sleep $COOL_DOWN_TIME
      #   continue
      # fi

      overallOverhead=$((end_time - start_time - $TIMEOUT))
      echo "overallOverheadTime=$overallOverhead"
      echo "overallOverheadTime=$overallOverhead" >>tmp
      cp tmp $TARGET_FILE
      rm tmp

      echo "cleaning..."
      killall java
      sleep $COOL_DOWN_TIME
    done
  done
done
