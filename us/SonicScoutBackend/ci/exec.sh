#!/bin/sh
# Recommendation: Place this file in source control.
# Auto-generated by `./dk dksdk.project.new` of SquirrelScout.
set -euf
# This script exists because each invocation of `opamrun exec` in Linux dockcross
# is a new container. That means `yum install` is not persistent across `opamrun`.
# We do `yum install` and any other container operations inside this script,
# which must be invoked with `opamrun exec`.

dkml_host_abi=$1
shift

# Prerequisites for CMake configure, especially opam
case $dkml_host_abi in
  linux_*)
    if [ ! -e /usr/bin/rsync ]; then
      if command -v yum; then
        if [ "$(id -u)" -eq 0 ]; then yum install -y rsync; else sudo yum install -y rsync; fi
      else
        if [ "$(id -u)" -eq 0 ]; then apt-get -q install -y rsync; else sudo apt-get -q install -y rsync; fi
      fi
    fi
    ;;
esac

set -x
exec "$@"
