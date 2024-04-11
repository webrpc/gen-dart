#!/bin/bash
set -e

export PORT=9988

tmp=".tmp"
schema="$tmp/test.ridl"
webrpcgen="$tmp/webrpc-gen"
webrpctest="$tmp/webrpc-test"

# for testing against a local version of webrpc. Update your path
# webrpcgen="../../webrpc/bin/webrpc-gen"
# webrpctest="../../webrpc/bin/webrpc-test"

./$webrpctest -version
./$webrpctest -print-schema > $schema
./$webrpcgen -schema=$schema -target=../ -client -out=$tmp/client.dart

./$webrpctest -server -port=$PORT -timeout=5s &

# Wait until http://localhost:$PORT is available, up to 10s.
for (( i=0; i<100; i++ )); do nc -z localhost $PORT && break || sleep 0.1; done

dart test --chain-stack-traces