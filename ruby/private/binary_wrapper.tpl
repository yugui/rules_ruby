#!/bin/sh

if [ ! -s ../MANIFEST ]; then
  echo "WARNING: it does not look to be at the .runfiles directory" >&2
fi

echo $* >&2
{interpreter} --disable-gems {init_flags} {rubyopt} -I. {main} $*
