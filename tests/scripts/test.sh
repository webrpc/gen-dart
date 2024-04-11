#!/bin/bash
set -e

Help()
{
   # Display Help
   echo "Generates the test client and server Dart code and runs tests against it."
   echo
   echo "Syntax: test.sh [-r|h]"
   echo "options:"
   echo "h prints this help message"
   echo "r path/to/webrpc/bin if using a local version of the base webrpc repo"
   echo
}

tmp=".tmp"

webrpc_root=$tmp
while getopts ":hr:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      r) # Enter a name
         webrpc_root=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

export PORT=9988

schema="$tmp/test.ridl"
webrpcgen="$webrpc_root/webrpc-gen"
webrpctest="$webrpc_root/webrpc-test"

./$webrpctest -version
./$webrpctest -print-schema > $schema
./$webrpcgen -schema=$schema -target=../ -client -out=$tmp/client.dart

./$webrpctest -server -port=$PORT -timeout=5s &

# Wait until http://localhost:$PORT is available, up to 10s.
for (( i=0; i<100; i++ )); do nc -z localhost $PORT && break || sleep 0.1; done

dart test --chain-stack-traces