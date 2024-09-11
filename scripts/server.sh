#!/usr/bin/bash

SERVER_BINDING="4-7"
SERVER_CMD="./main"

cd ../server
taskset -c $SERVER_BINDING $SERVER_CMD &