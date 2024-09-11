#!/usr/bin/bash

USAGE="$0 (target parameter/all)"
show_usage() {
  echo "Error: $1"
  echo $USAGE
  exit 1
}

VERBOSE=false
 echo "$@"
if echo "$@" | grep -q "\-v"; then
  echo "verbose mode"
  VERBOSE=true
fi

echo_verbose() {
  if [ "$VERBOSE" == "true" ]; then
    echo $1
  fi
}

if [ $# -lt 1 ]; then
  show_usage "Missing program argument"
fi
PARAM=$1

if [ "$PARAM" == "all" ]; then
  for param in found overallOverheadTime memoryUsage; do
    if [ "$VERBOSE" == "true" ]; then
      $0 $param -v
    else
      $0 $param
    fi
  done

  exit 0
fi

if [ ! -d "./results" ]; then
  mkdir "./results"
fi

TARGET_DIR="./results/$PARAM-$(date +%Y%m%d%H%M%S)"
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

  for file in $RESULTS_DIR/test-*; do
    if [ -f "$file" ]; then
      echo_verbose "processing $file"
      file_name=$(basename "$file")
      threads=$(echo "$file_name" | awk -F'-' '{print $2}')
      connections=$(echo "$file_name" | awk -F'-' '{print $3}')
      echo_verbose "threads=$threads, connections=$connections"

      param_val=$(cat $file | grep "$PARAM=" | cut -d"=" -f2)
      found_val=$(cat $file | grep "found=" | cut -d"=" -f2)
      target_file="$TARGET_DIR/t-$threads.csv"
      if [ ! -f $target_file ]; then
        echo "name,connections,$PARAM" >$target_file
      fi

      if [[ -n "$found_val" ]]; then
        echo_verbose "$name,$connections,$param_val"
        echo "$name,$connections,$param_val" >>$target_file
      else
        echo "No found in $file in $name"
      fi

    fi
  done
done
