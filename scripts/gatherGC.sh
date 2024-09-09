#!/usr/bin/bash

if [ ! -d "./results" ]; then
  mkdir "./results"
fi

TARGET_DIR="./results/GC-data-$(date +%Y%m%d%H%M%S)"
mkdir $TARGET_DIR

for name in go gJvm gNative cJvm cNative singleThreaded gurl; do
  case $name in
  go)
    RESULTS_DIR="../go/results"
    ;;
  gJvm)
    RESULTS_DIR="../gears/jvm/results"
    ;;
  gNative)
    RESULTS_DIR="../gears/native/results"
    ;;
  cJvm)
    RESULTS_DIR="../cats/jvm/results"
    ;;
  cNative)
    RESULTS_DIR="../cats/native/results"
    ;;
  singleThreaded)
    RESULTS_DIR="../single-threaded/results"
    ;;
  gurl)
    RESULTS_DIR="../gurl/native/results"
    ;;

  *)
    echo "should not reach here"
    exit 1
    ;;
  esac

  if [ ! -d $RESULTS_DIR ]; then
    echo "No results directory for $name"
    continue
  fi

  CURRENT_TARGET_DIR="$TARGET_DIR/$name"
  mkdir $CURRENT_TARGET_DIR

  for file in $RESULTS_DIR/gc-stats-*; do
    if [ -f "$file" ]; then
      echo "copying $file"
      cp $file $CURRENT_TARGET_DIR
    fi
  done
done
