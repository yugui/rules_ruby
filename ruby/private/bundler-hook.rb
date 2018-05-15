require 'rubygems'
require 'rubygems/ext'

class Gem::Ext::Builder
  # Monkey-patching to let bundler skip building native extensions
  def build_extensions
  end
end
