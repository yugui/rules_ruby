#!/usr/bin/env bash
# Ruby-port of the Bazel's wrapper script for nodejs and the one for python

# Copyright 2017 The Bazel Authors. All rights reserved.
# Copyright 2019 BazelRuby Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Immediately exit if any command fails.
set -e

# --- begin runfiles.bash initialization ---
# Source the runfiles library:
# https://github.com/bazelbuild/bazel/blob/master/tools/bash/runfiles/runfiles.bash
# The runfiles library defines rlocation, which is a platform independent function
# used to lookup the runfiles locations. This code snippet is needed at the top
# of scripts that use rlocation to lookup the location of runfiles.bash and source it
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
    if [[ -f "$0.runfiles_manifest" ]]; then
      export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
    elif [[ -f "$0.runfiles/MANIFEST" ]]; then
      export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
    elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
      export RUNFILES_DIR="$0.runfiles"
    fi
fi
if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
  source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash " \
            "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
  echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
  exit 1
fi
# --- end runfiles.bash initialization ---

function find_runfiles() {
  local self
  case "$1" in
    /*) self="$1" ;;
    *) self="$PWD/$1" ;;
  esac

  if [[ -n "${RUNFILES_MANIFEST_ONLY+x}" ]]; then
    # Windows only has a manifest file instead of symlinks.
    runfiles=${RUNFILES_MANIFEST_FILE%/MANIFEST}
  elif [[ -n "${TEST_SRCDIR+x}" ]]; then
    # Case 4, bazel has identified runfiles for us.
    runfiles="${TEST_SRCDIR}"
  else
    while true; do
      if [[ -e "$self.runfiles" ]]; then
        runfiles="$self.runfiles"
        break
      fi

      if [[ $self == *.runfiles/* ]]; then
        runfiles="${self%%.runfiles/*}.runfiles"
        # don't break; this is a last resort for case 6b
      fi

      if [[ ! -L "$self" ]]; then
        break;
      fi

      readlink="$(readlink "$self")"
      if [[ "$readlink" = /* ]]; then
        self="$readlink"
      else
        # resolve relative symlink
        self="${self%%/*}/$readlink"
      fi
    done

    if [[ -z "$runfiles" ]]; then
      echo " >>>> FAIL: RUNFILES environment variable is not set. <<<<" >&2
      exit 1
    fi
  fi
  echo -n "$runfiles"
}

function main() {
  local moulde_space
  runfiles=$(find_runfiles $0)
}

exec env -i \
  RUNFILES="$runfiles"
  {interpreter} \
  --disable-gems \
  {init_flags} \
  {rubyopt} \
$PATH_PREFIX{interpreter} --disable-gems {init_flags} {rubyopt} -I${PATH_PREFIX} {main} "$@"
