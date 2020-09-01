#!/bin/bash

set -e

rm -rfv ./test
mkdir -pv ./test/output
mkdir -pv "./test/input/sub directory"
touch "test/input/root.mkv"
touch "test/input/sub directory/child.mkv"
touch "test/input/sub directory/With spaces (1999).mkv"
touch "test/input/With spaces: the sequel (2004).mkv"

DEBUG=1 ./encode-drop.sh ./test/input ./test/output

tree ./test

rm -rfv ./test

