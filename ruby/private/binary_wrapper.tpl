#!/usr/bin/env pythonn

# Ruby-port of the Bazel's wrapper script for Python

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


def find_module_space
  stub_filename = File.absolute_path($0)
  module_space = "#{stub_filename}.runfiles"
  loop do
    case
    when File.dir?(module_space)
      return module_space
    when %r!(.*\.runfiles)/.*!o =~ stub_filename
      return $1
    when File.symlink?(stub_filename)
      target = File.readlink(stub_filename)
      stub_filename = File.absolute_path(target, File.dirname(stub_filename))
    else
      break
    end
  end
  raise "Cannot find .runfiles directory for #{$0}"
end

def main(args)
  module_space = find_module_space
end

if $0 == __file__
  main(ARGV)
end

$PATH_PREFIX{interpreter} --disable-gems {init_flags} {rubyopt} -I${PATH_PREFIX} {main} "$@"
