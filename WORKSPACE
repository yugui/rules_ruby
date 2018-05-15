workspace(name = "com_github_yugui_rules_ruby")

load("@//ruby:def.bzl", "ruby_register_toolchains")

ruby_register_toolchains()

load("@//ruby/private:bundle.bzl", "bundle_install")

bundle_install(
    name = "bundler_test",
    excludes = {
        "jsonnet": ["ext/**/*"],
        "mini_portile2": ["test/**/*"],
    },
    gemfile = "//:examples/Gemfile",
    gemfile_lock = "//:examples/Gemfile.lock",
    rules_ruby_workspace = "@",
)

http_archive(
    name = "jsonnet",
    sha256 = "524b15ab7780951683237061bc675313fc95942e7164f59a7ad2d1c46341c108",
    strip_prefix = "jsonnet-0.10.0",
    urls = [
        "https://mirror.bazel.build/github.com/google/jsonnet/archive/v0.10.0.tar.gz",
        "https://github.com/google/jsonnet/archive/v0.10.0.tar.gz",
    ],
)
