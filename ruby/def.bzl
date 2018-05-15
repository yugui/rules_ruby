# Repository rules
load(
    "//ruby/toolchain:toolchains.bzl",
    "ruby_register_toolchains",
)

load(
    "//ruby/private:library.bzl",
    "ruby_library",
)

load(
    "//ruby/private:binary.bzl",
    "ruby_binary",
    "ruby_test",
)
