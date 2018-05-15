package(default_visibility = ["//visibility:private"])

genrule(
    name = "jsonnet_wrap.link",
    srcs = [
        ":jsonnet_wrap_lib",
        "@jsonnet//core:libjsonnet",
    ],
    outs = ["jsonnet_wrap.bundle"],
    cmd = "$(CC) $(CC_FLAGS) -dynamic -bundle -o $@ -Wl,-all_load $(SRCS) " + " ".join([
        "-fstack-protector",
        "-Wl,-undefined,dynamic_lookup",
        "-Wl,-multiply_defined,suppress",
    ]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "jsonnet_wrap_lib",
    srcs = [
        "callbacks.c",
        "helpers.c",
        "jsonnet.c",
        "jsonnet_values.c",
        "ruby_jsonnet.h",
        "vm.c",
    ],
    copts = [
        "-I.",
        "-I.",
        "-DHAVE_LIBJSONNET_H",
        "-D_XOPEN_SOURCE",
        "-D_DARWIN_C_SOURCE",
        "-D_DARWIN_UNLIMITED_SELECT",
        "-D_REENTRANT",
        "-O3",
        "-ggdb3",
        "-Wall",
        "-Wextra",
        "-Wno-unused-parameter",
        "-Wno-parentheses",
        "-Wno-long-long",
        "-Wno-missing-field-initializers",
        "-Wno-tautological-compare",
        "-Wno-parentheses-equality",
        "-Wno-constant-logical-operand",
        "-Wno-self-assign",
        "-Wunused-variable",
        "-Wimplicit-int",
        "-Wpointer-arith",
        "-Wwrite-strings",
        "-Wdeclaration-after-statement",
        "-Wshorten-64-to-32",
        "-Wimplicit-function-declaration",
        "-Wdivision-by-zero",
        "-Wdeprecated-declarations",
        "-Wextra-tokens",
    ],
    linkopts = [
        "-L.",
        "-fstack-protector",
        "-Wl,-undefined,dynamic_lookup",
        "-Wl,-multiply_defined,suppress",
    ],
    linkstatic = True,
    deps = [
        "@jsonnet//core:libjsonnet",
        "@org_ruby_lang_ruby_host//:ruby_hdrs",
    ],
    alwayslink = True,
)
# vim: set ft=bzl :
