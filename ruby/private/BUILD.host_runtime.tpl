load(
  "@com_github_yugui_rules_ruby//ruby:def.bzl",
  "ruby_library",
)

package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "ruby_bin",
    srcs = [{ruby_basename}],
    data = [{ruby_path}, ":runtime"],
)

# exports_files(["init_loadpath.rb"])
filegroup(
  name = "init_loadpath",
  srcs = ["init_loadpath.rb"],
  data = ["loadpath.lst"],
)

cc_import(
    name = "libruby",
    hdrs = glob([{hdrs}]),
    static_library = {static_library},
    shared_library = {shared_library},
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
          {ruby_path},
          "ruby",
          "init_loadpath.rb",
          "loadpath.lst",
          "BUILD.bazel",
          "WORKSPACE",
        ],
    ),
)

# vim: set ft=bzl :
