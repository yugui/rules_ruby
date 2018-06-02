#
# Provides rules to test actions which runs ruby at the bulid phase
#

load(
    "//ruby/private/tools:context.bzl",
    "ruby_context",
)

def _run_ruby_impl(ctx):
  ruby = ruby_context(ctx)
  ruby.run_ruby_file(
      ruby,
      script = ctx.file.src,
      args = ctx.args,
  )

run_ruby = rule(
    _run_ruby_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "args": attr.string_list(),
    },
)
