load(
  "@com_github_yugui_rules_ruby//ruby:def.bzl",
  "ruby_library",
)

package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "ruby_bin",
    srcs = ["{ruby_basename}"],
    data = ["{ruby_path}", ":runtime"],
)

# exports_files(["init_loadpath.rb"])
filegroup(
  name = "init_loadpath",
  srcs = ["init_loadpath.rb"],
  data = ["loadpath.lst"],
)

cc_library(
    name = "libruby",
    deps = [
        ":ruby_hdrs",
        ":libruby_import",
        ":libruby_deps",
    ],
)

cc_library(
    name = "ruby_hdrs",
    hdrs = glob(["{header_glob}/**/*.h"]),
    #strip_include_prefix = "{rubyhdrdir}",
    #visibility = ["//visibility:private"],
    #includes = ["x86_64-darwin17"],
    includes = [
        "{rubyhdrdir}",
        "{rubyhdrdir}/x86_64-darwin17",
    ]
)

cc_import(
    name = "libruby_import",
    static_library = {static_library},
    shared_library = {shared_library},
    visibility = ["//visibility:private"],
)

cc_library(
    name = "libruby_deps",
    srcs = {dependent_libraries},
)

filegroup(
  name = "bundler",
  srcs = ["bundler/exe/bundler"],
  data = glob(["bundler/**/*.rb"]),
)

filegroup(
    name = "runtime",
    srcs = glob(
        include = ["**/*"],
        exclude = [
          "{ruby_path}",
          "ruby",
          "init_loadpath.rb",
          "loadpath.lst",
          "BUILD.bazel",
          "WORKSPACE",
          "{libdir}/**/gems/**/*",
        ],
    ),
)

# vim: set ft=bzl :
