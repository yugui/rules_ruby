def _ruby_toolchain_impl(ctx):
  return [platform_common.ToolchainInfo(
      interpreter = ctx.executable.interpreter,
      interpreter_rule = ctx.attr.interpreter,
      runtime = ctx.attr.runtime,
      init_files = ctx.attr.init_files,
      bundler = ctx.attr.bundler,
      rubyopt = ctx.attr.rubyopt,
  )]

_ruby_toolchain = rule(
    implementation = _ruby_toolchain_impl,
    attrs = {
        "interpreter": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
        "bundler": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
        "init_files": attr.label_list(
            allow_files = True,
            cfg = "target",
        ),
        "runtime": attr.label(
            mandatory = True,
            allow_files = True,
            cfg = "host",
        ),
        "rubyopt": attr.string_list(
            default = [],
        ),
    },
)

def ruby_toolchain(name, interpreter, bundler, runtime, host, init_files=[], rubyopt=[], target=None, **kwargs):
  impl_name = name + "-sdk"
  if not target:
    target = host

  _ruby_toolchain(
      name = impl_name,
      interpreter = interpreter,
      bundler = bundler,
      init_files = init_files,
      rubyopt = rubyopt,
      runtime = runtime,
  )

  native.toolchain(
      name = name,
      toolchain_type = "@com_github_yugui_rules_ruby//ruby/toolchain:toolchain",
      toolchain = ":%s" % impl_name,
#      exec_compatible_with = [host],
#      target_compatible_with = [target],
      **kwargs
  )
