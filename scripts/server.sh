#!/usr/bin/bash

if [ -z "$SERVER_BINDING" ]; then
  echo "no SERVER_BINDING variable found"
  exit 1
fi
echo "SERVER_BINDING=$SERVER_BINDING"

if [ -z "$SERVER_CONFIG_PATH" ]; then
  echo "no SERVER_CONFIG_PATH variable found"
  exit 1
fi
echo "SERVER_CONFIG_PATH=$SERVER_CONFIG_PATH"

SERVER_CMD="./main $SERVER_CONFIG_PATH"

cd ../server
taskset -c $SERVER_BINDING $SERVER_CMD &
