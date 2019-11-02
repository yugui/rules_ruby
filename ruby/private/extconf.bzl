load("//ruby/private:binary.bzl", "ruby_binary")

def ruby_extconf_library(name,
                         extconf="extconf.rb",
                         extconf_deps=[],
                         extconf_data=[],
                         **attrs):
  extconf_binary = "%s-extconf.bin" % name
  ruby_binary(
      name = extconf_binary,
      main = extconf,
      srcs = [extconf],
      deps = extconf_deps,
      data = extconf_data,
      visibility = ["//visibility:private"],
  )

  native.genrule(
      name = "%s-extconf" % name,
      exec_tools = [":%s" % extconf_binary],
      cmd = "$(location :%s); mv Makefile $@" % extconf_binary,
      outs = ["Makefile"],
      visibility = ["//visibility:private"],
  )
