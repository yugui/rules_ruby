def _run_ruby(ruby, args):
  arguments = ['env', '-i', ruby.interpreter_realpath] + args
  environment = {"RUBYOPT": "--disable-gems"}

  result = ruby._ctx.execute(arguments, environment=environment)
  if result.return_code:
    message = "Failed to run a ruby script with {}: {}".format(
        ruby.interpreter_realpath, result.stderr)
    fail(message)
  return result.stdout


def _eval_ruby(ruby, script, options=None):
  arguments = []
  if options:
    arguments.extend(options)
  arguments.extend(['-e', script])
  return _run_ruby(ruby, arguments)


def _rbconfig(ruby, name):
  options = ['-rrbconfig']
  script = 'print RbConfig::CONFIG[{}]'.format(
      # Here we actually needs String#dump in Ruby but
      # repr in Python is compatible enough.
      repr(name),
  )
  return _eval_ruby(ruby, script=script, options=options)


def _expand_rbconfig(ruby, expr):
  options = ['-rrbconfig']
  script = 'print RbConfig.expand({})'.format(
      # Here we actually needs String#dump in Ruby but
      # repr in Python is compatible enough.
      repr(expr),
  )
  return _eval_ruby(ruby, script=script, options=options)


def ruby_repository_context(repository_ctx, interpreter_path):
  interpreter_path = interpreter_path.realpath
  interpreter_name = interpreter_path.basename

  rel_interpreter_path = str(interpreter_path)
  if rel_interpreter_path.startswith('/'):
    rel_interpreter_path = rel_interpreter_path[1:]

  return struct(
      # Location of the interpreter
      rel_interpreter_path = rel_interpreter_path,
      interpreter_name = interpreter_path.basename,
      interpreter_realpath = interpreter_path,

      # Standard repository structure for ruby runtimes

      # Helper methods
      run = _run_ruby,
      eval = _eval_ruby,
      rbconfig = _rbconfig,
      expand_rbconfig = _expand_rbconfig,

      _ctx = repository_ctx,
  )
