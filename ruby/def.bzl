load(
    "@//ruby/private:library.bzl",
    _library = "ruby_library",
)

load(
    "@//ruby/private:binary.bzl",
    _binary = "ruby_binary",
    _test = "ruby_test",
)

load(
    "@com_github_yugui_rules_ruby//ruby/private:extconf.bzl",
    _extconf = "ruby_extconf_library",
)

ruby_library = _library
ruby_binary = _binary
ruby_test = _test
ruby_extconf_library = _extconf
