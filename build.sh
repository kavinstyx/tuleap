#!/bin/bash

BASEDIR=$(dirname $0)

pushd $BASEDIR

docker build -t jariasl/tuleap \
.

popd
