#!/usr/bin/bash

USAGE="$0 (go|gJvm|gNative|cJvm|cNative)"

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
TIMEOUT=10000 # ms
REPEATE_COUNT=3
COOL_DOWN_TIME=2 # s

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

  sbt rootNative/run
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

  sbt rootNative/run
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
  cd "$SINGE_THREADED_ROOT/.."

  sbt run
  if [ $? -ne 0 ]; then
    finish "Failed to build single threaded native program"
  fi

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
all)
  echo "Running all benchmarks"
  for name in go gJvm gNative cJvm cNative singleThreaded; do
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
  for connections in 1 10 100 1000 10000; do
    echo "Running $NAME with $threads threads and $connections connections:"
    for ((i = 0; i < REPEATE_COUNT; i++)); do
      set_vars $threads $connections $i
      cmd="taskset -c 0-$((threads - 1)) /usr/bin/time -f "memoryUsage=%M" $CMD | tee tmp"
      start_time=$(date +%s%3N)
      eval $cmd
      end_time=$(date +%s%3N)
      overallOverhead=$((end_time - start_time - $TIMEOUT))
      echo "overallOverheadTime=$overallOverhead"
      echo "overallOverheadTime=$overallOverhead" >>tmp
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
