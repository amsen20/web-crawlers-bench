#!/usr/bin/bash

SERVER_BINDING="32-63"
SERVER_CMD="./main"

cd ../server
taskset -c $SERVER_BINDING $SERVER_CMD &
