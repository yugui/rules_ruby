require 'erb'

require_relative 'makefile_parser'

def generate_build(io)
  makefile = Extconf::Makefile.parse(io)

  filter = ->(x) { x.sub(%r"^./", '') }
  srcs = makefile.value('SRCS').split(/\s+/).map(&filter)
  hdrs = makefile.value('HDRS').split(/\s+/).map(&filter)

  ldflags = makefile.value('ldflags').split(/\s+/)
  incflags = makefile.value('INCFLAGS').split(/\s+/)
  cppflags = makefile.value('CPPFLAGS').split(/\s+/)
  cxxflags = makefile.value('cxxflags').split(/\s+/)
  copts = incflags + cppflags + cxxflags
  deps = []

  name = makefile.value('TARGET_NAME')

  path = File.join(File.dirname(__FILE__), 'BUILD.bazel.erb')
  template = ERB.new(File.read(path), nil, '-')
  template.filename = path
  template.result(binding)
end


if $0 == __FILE__
  puts generate_build($<)
end
