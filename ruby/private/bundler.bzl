_DEFAULT_VERSION = "1.16.1"

def install_bundler(ruby, interpreter, install_bundler, dest, version=_DEFAULT_VERSION):
  ruby.run_ruby(ruby, script_file = install_bundler, argv = [version, dest])
