def _run_args(ruby, script=None, extra_args=[], script_args=[]):
  args = ruby.actions.args()

  args.add('--disable-gems')
  for t in ruby.toolchain.init_files:
    for f in t.files:
      args.add("-r./%s" % f.path)
  for opt in ruby.toolchain.rubyopt:
    args.add(opt)
  for opt in extra_args:
    args.add(opt)

  if bundle and bundle[RubyLibrary]:
    for inc in bundle[RubyLibrary].ruby_incpaths:
      args.add_all("-r", inc)
    args.add_all(bundle[RubyLibrary].rubyopt)

  if script:
    args.add(script)
  for arg in script_args:
    args.add(arg)
  return args

def _run_file(ruby, script, outputs, bundle=None, progress_message=None):
  tools = depset(
      transitive = [
          ruby.toolchain.interpreter_rule[DefaultInfo].data_runfiles.files,
          ruby.toolchain.runtime.files,
      ] + [
          t.files for t in ruby.toolchain.init_files
      ] + [
          t[DefaultInfo].data_runfiles.files for t in ruby.toolchain.init_files
      ]

  )
  if bundle:
    tools = depset(
        transitive = [
            tools,
            bundle[RubyLibrary].transitive_ruby_srcs
        ],
    )
  for f in tools:
    print(f)

  ruby.actions.run(
      outputs = outputs,
      inputs = tools + [script],
      executable = ruby.toolchain.interpreter,
      arguments = [_run_args(ruby, script, extra_args=["-r", "external/bundler_test"], bundle=bundle)],
      progress_message = progress_message,
  )

def ruby_context(ctx):
  return struct(
      actions = ctx.actions,
      toolchain = ctx.attr.toolchain[platform_common.ToolchainInfo],

      run_ruby_file = _run_file,
  )
