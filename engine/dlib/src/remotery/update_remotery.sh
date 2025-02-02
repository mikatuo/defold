#!/usr/bin/env bash

set -e


REMOTERY_REPO=$1

if [ -z "${REMOTERY_REPO}" ]; then
    echo "Usage: ./update.sh <path to Remotery repo>"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "${DYNAMO_HOME}" ]; then
    echo "DYNAMO_HOME is not set!"
    exit 1
fi

echo "Found DYNAMO_HOME=${DYNAMO_HOME}"
DEFOLD_REPO=${DYNAMO_HOME}/../..


cp -v ${REMOTERY_REPO}/lib/*.c ${DEFOLD_REPO}/engine/dlib/src/remotery/lib/
cp -v ${REMOTERY_REPO}/lib/*.h ${DEFOLD_REPO}/engine/dlib/src/dmsdk/external/remotery/Remotery.h
cp -v -r ${REMOTERY_REPO}/vis/ ${DEFOLD_REPO}/editor/resources/engine-profiler/remotery/vis

echo "Applying patch"

(cd ${DEFOLD_REPO} && git apply ./engine/dlib/src/remotery/defold.patch)

# Since we want to be able to start the server stand along, we want to keep index.html intact
# but we need a patched version to be served from the editor
cp -v ${DEFOLD_REPO}/editor/resources/engine-profiler/remotery/vis/index.html ${DEFOLD_REPO}/editor/resources/engine-profiler/remotery/vis/orig.index.html
(cd ${DEFOLD_REPO} && git apply ./engine/dlib/src/remotery/defoldvis.patch)
cp -v ${DEFOLD_REPO}/editor/resources/engine-profiler/remotery/vis/index.html ${DEFOLD_REPO}/editor/resources/engine-profiler/remotery/vis/patched.index.html
mv -v ${DEFOLD_REPO}/editor/resources/engine-profiler/remotery/vis/orig.index.html ${DEFOLD_REPO}/editor/resources/engine-profiler/remotery/vis/index.html

echo "Done"

