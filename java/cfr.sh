#!/usr/bin/env bash

# get the script directory path
source="${BASH_SOURCE[0]}"
while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )"
  source="$(readlink "$source")"
  [[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
scriptdir="$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )"

if [[ "$(uname -s)" == "CYGWIN"* ]]; then
    jarpath=$(cygpath -w "$scriptdir/cfr-0.149.jar")
    classes=$(cygpath -w "$@")
else
    jarpath="$scriptdir/cfr-0.149.jar"
    classes="$@"
fi
if [ ! -f $jarpath ]; then
    echo "jar lib $jarpath not found"
    return 1
fi
java -jar $jarpath $classes
