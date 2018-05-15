load("//ruby/private:library.bzl", "ruby_library")
load("//ruby/private:context.bzl", _ruby_context="ruby_context")
load(
    ":providers.bzl",
    "RubyLibrary",
)


def _extconf_impl(ctx):
  ruby = _ruby_context(ctx)
  makefile = ctx.actions.declare_file('Makefile')
  ruby.run_ruby_file(
      ruby,
      script = ctx.file.extconf,
      progress_message = "configuring %s" % ctx.attr.name,
      outputs = [ctx.outputs._makefile],
      bundle = ctx.attr.bundle,
  )

_extconf = rule(
    implementation = _extconf_impl,
    attrs = {
        "extconf": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        # TODO(yugui) It might be better to support as "dev_dependency",
        "bundle": attr.label(
            providers = [RubyLibrary],
        ),
        "toolchain": attr.label(
            default = "@com_github_yugui_rules_ruby//ruby/toolchain:ruby_sdk",
            providers = [platform_common.ToolchainInfo],
        ),
    },
    outputs = {
        "_makefile": "Makefile",
    },
)

def _ruby_extension_impl(ctx):
  pass

_ruby_extension = rule(
    implementation = _ruby_extension_impl,
    attrs = {
        "extconf": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "toolchain": attr.label(
            default = "@com_github_yugui_rules_ruby//ruby/toolchain:ruby_sdk",
            providers = [platform_common.ToolchainInfo],
        )
    },
)

def ruby_extension_library(name, extconf, srcs, bundle=None, **kwargs):
  _extconf(
      name = "%s.extconf" % name,
      extconf = extconf,
      bundle = bundle,
      srcs = srcs,
  )
  _ruby_extension(
      name = "%s.ext" % name,
      #libname = name,
      extconf = extconf,
      srcs = srcs,
  )

  ruby_library(
      name = name,
      srcs = [":%s.ext" % name],
      **kwargs
  )
