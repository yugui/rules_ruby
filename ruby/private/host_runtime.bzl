load(":bundler.bzl", "install_bundler")
load(":repository_context.bzl", "ruby_repository_context")

def _is_subpath(path, ancestors):
  """Determines if path is a subdirectory of one of the ancestors"""
  for ancestor in ancestors:
    if not ancestor.endswith('/'):
      ancestor += '/'
    if path.startswith(ancestor):
      return True
  return False

def _relativate(path):
    # Assuming that absolute paths start with "/".
    # TODO(yugui) support windows
    if path.startswith('/'):
      return path[1:]
    else:
      return path

def _list_libdirs(ruby):
  """List the LOAD_PATH of the ruby"""
  paths = ruby.eval(ruby, 'print $:.join("\\n")')
  paths = sorted(paths.split("\n"))
  rel_paths = [_relativate(path) for path in paths]
  return (paths, rel_paths)

def _list_dylibs(ctx, ruby):
  """List the paths to the dynamic libraries which libruby depends on"""
  return ruby.run(ruby, [ctx.path(ctx.attr._list_dylibs)]).split("\n")

def _install(ctx, path):
  rel_path = _relativate(path)
  if not ctx.path(rel_path).exists:
    ctx.symlink(path, rel_path)
  return rel_path

def _install_dir(ctx, ruby, name):
  path = ruby.rbconfig(ruby, name)
  return _install(ctx, path)

def _maybe_path(ctx, path):
  if ctx.path(path).exists:
    return path
  else:
    return None

INTERPRETER_WRAPPER = """
#!/bin/sh
DIR=`dirname $0`
exec $DIR/bin/ruby $*
"""

def _install_host_ruby(ctx, ruby):
  # Places SDK
  ctx.symlink(ctx.attr._init_loadpath_rb, "init_loadpath.rb")
  ctx.symlink(ruby.interpreter_realpath, ruby.rel_interpreter_path)
  ctx.symlink(ruby.rel_interpreter_path, "bin/ruby")
  ctx.file(
      ruby.interpreter_name,
      INTERPRETER_WRAPPER, #% ruby.rel_interpreter_path,
      executable = True,
  )

  includedir = _install_dir(ctx, ruby, "includedir")
  libdir = _install_dir(ctx, ruby, "libdir")
  rubyhdrdir = _install_dir(ctx, ruby, "rubyhdrdir")

  paths, rel_paths = _list_libdirs(ruby)
  for path, rel_path in zip(paths, rel_paths):
    if not ctx.path(rel_path).exists:
       ctx.symlink(path, rel_path)
  ctx.file("loadpath.lst", "\n".join(rel_paths))

  dylibs = []
  for dylib in _list_dylibs(ctx, ruby):
    dylibs.append(_install(ctx, dylib))

  return struct(
      includedir = includedir,
      libdir = libdir,
      rubyhdrdir = rubyhdrdir,
      static_library = _maybe_path(
          ctx,
          _relativate(ruby.expand_rbconfig(ruby, '${libdir}/${LIBRUBY_A}')),
      ),
      shared_library = _maybe_path(
          ctx,
          _relativate(ruby.expand_rbconfig(ruby, '${libdir}/${LIBRUBY_SO}')),
      ),
      dependent_libraries = dylibs,
  )


def _ruby_host_runtime_impl(ctx):
  # Locates path to the interpreter
  if ctx.attr.interpreter_path:
    interpreter_path = ctx.path(ctx.attr.interpreter_path)
  else:
    interpreter_path = ctx.which("ruby")
  if not interpreter_path:
    fail(
        "Command 'ruby' not found. Set $PATH or specify interpreter_path",
        "interpreter_path",
    )

  ruby = ruby_repository_context(ctx, interpreter_path)

  installed = _install_host_ruby(ctx, ruby)
  install_bundler(
      ctx,
      interpreter_path,
      ctx.path(ctx.attr._install_bundler).realpath,
      'bundler',
  )

  ctx.template(
      'BUILD.bazel',
      ctx.attr._buildfile_template,
      substitutions = {
          "{ruby_path}": ruby.rel_interpreter_path,
          "{ruby_basename}": ruby.interpreter_name,
          "{libdir}": installed.libdir,
          "{rubyhdrdir}": installed.rubyhdrdir,
          "{static_library}": repr(installed.static_library),
          "{shared_library}": repr(installed.shared_library),
          "{dependent_libraries}": repr(installed.dependent_libraries),
      },
  )

ruby_host_runtime = repository_rule(
    implementation = _ruby_host_runtime_impl,
    attrs = {
        "interpreter_path": attr.string(),

        "_init_loadpath_rb": attr.label(
            default = "@com_github_yugui_rules_ruby//:ruby/tools/init_loadpath.rb",
            allow_single_file = True,
        ),
        "_list_dylibs": attr.label(
            default = "@com_github_yugui_rules_ruby//:ruby/private/list-dylibs.rb",
            allow_single_file = True,
        ),
        "_install_bundler": attr.label(
            default = "@com_github_yugui_rules_ruby//ruby/private:install-bundler.rb",
            allow_single_file = True,
        ),
        "_buildfile_template": attr.label(
            default = "@com_github_yugui_rules_ruby//ruby/private:BUILD.host_runtime.tpl",
            allow_single_file = True,
        ),
    },
)
