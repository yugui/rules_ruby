require 'rubygems'


def main(gem_name, bin_name)
  unless Gem::Specification.respond_to? :default_specifications_dir
    warn "No"
    return
  end

  spec = Gem::Specification.find {|spec|
    spec.name == gem_name && spec.default_gem?
  }
  print spec.bin_file(bin_name) if spec
end


if $0 == __FILE__
  main(*ARGV)
end
