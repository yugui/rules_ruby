#!/usr/bin/ruby

require 'foo'

bar = Foo::Bar.new
puts Foo::VERSION
puts Foo::UseNative.jsonnet_version
puts
