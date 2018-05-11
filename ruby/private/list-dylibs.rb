require 'shellwords'
require 'rbconfig'

DARWIN_BLACKLIST = %w[ libSystem libobjc ]
def query_darwin(loadable)
  deps = `otool -L #{Shellwords.escape loadable}`
  paths = deps.scan(/^\t(.*.dylib) \(/).map(&:first)
  paths.reject do |path|
    DARWIN_BLACKLIST.any? {|base| File.basename(path, '.dylib').start_with?(base) }
  end
end

def main
  ruby = RbConfig.expand('${bindir}/${RUBY_INSTALL_NAME}')
  os = RbConfig::CONFIG['host_os']

  case os
  when /^darwin/
    libs = query_darwin(ruby)
  else
    raise "Operating system not supported: #{os}"
  end
  print libs.join("\n")
end

if $0 == __FILE__
  main
end
