#!/usr/bin/bash

USAGE="$0 (target parameter)"
show_usage () {
  echo "Error: $1"
  echo $USAGE
  exit 1
}

if [ $# -ne 1 ]; then
  show_usage "Missing program argument"
fi
PARAM=$1

if [ ! -d "./results" ]; then
  mkdir "./results"
fi

TARGET_DIR="./results/$PARAM-$(date +%Y%m%d%H%M%S)"
mkdir $TARGET_DIR

for name in go jvm native; do
  case $name in
    go)
      RESULTS_DIR="../go/results"
      ;;
    jvm)
      RESULTS_DIR="../gears/jvm/results"
      ;;
    native)
      RESULTS_DIR="../gears/native/results"
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
      threads=$(echo "$file" | awk -F'-' '{print $2}')
      connections=$(echo "$file" | awk -F'-' '{print $3}')
      
      param_val=$(cat $file | grep "$PARAM=" | cut -d"=" -f2)
      target_file="$TARGET_DIR/t-$threads-$param.csv"
      if [ ! -f $target_file ]; then
        echo "name,connections,$PARAM" > $target_file
      fi
      echo "$name,$connections,$param_val" >> $target_file
    fi
  done
done