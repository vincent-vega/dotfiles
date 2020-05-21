#!/usr/bin/env bash
if [[ "$(uname -s)" == "CYGWIN"* ]]; then
    jarpath=$(cygpath -w ${HOME}/dotfiles/java/cfr-0.149.jar)
    classes=$(cygpath -w "$@")
else
    jarpath="${HOME}/dotfiles/java/cfr-0.149.jar"
    classes="$@"
fi
if [ ! -f $jarpath ]; then
    echo "jar lib $jarpath not found"
    return 1
fi
java -jar $jarpath $classes
