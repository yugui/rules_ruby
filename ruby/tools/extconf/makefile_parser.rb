require_relative 'variable'
require_relative 'target'

module Extconf
  class Makefile
    def initialize(context, target_defs)
      @context = context
      @target_defs = target_defs
    end

    # An insufficient and inefficient parser of Makefile,
    # which is, however just good enough to deal with Makefiles
    # mkmf generates.
    def self.parse(io)
      context = Context.new
      target_defs = []
      last_target = nil
      MakefileReader.new(io).each_line do |line|
        if line[/^([[:alpha:]][[:alnum:]_]*)\s*=\s*(.*)/]
          name, defn = $1, $2
          context.set_variable(name, defn)

          last_target = nil
          next
        end

        if line[/^(.+?):(:)?\s*(.*)/]
          name, double_colon, deps = $1, $2, $3
          target = TargetDefinition.new(name, !!double_colon)
          target.add_raw_deps(deps)

          last_target = target
          target_defs << target
          next
        end

        if line[/^\t(.*)/]
          last_target.add_raw_commands($1)
          next
        end

        if line.empty?
          last_target = nil
          next
        end

        raise "huh? #{line.inspect}"
      end

      self.new(context, target_defs)
    end

    def targets
      targets = {}
      @target_defs.each do |t|
        t.names(context).each do |name|
          deps = t.deps(context)
          commands = t.commands(context)

          target = targets[name]
          if target
            target.add_deps(deps)
            target.add_commands(commands)
          else
           target = Target.new(name, deps, commands, t.double_colon?)
           targets[name] = target
          end
        end
      end

      targets
    end

    def value(name)
      var = @context.variable(name)
      var && var.evaluate(@context)
    end

    class MakefileReader
      def initialize(io)
        @io = io
      end

      def each_line
        last = ""
        @io.each_line do |line|
          next if line.start_with?('#')
          last += line.chomp
          if line.end_with?("\\")
            last[-1] = ''
          else
            yield last
            last = ""
          end
        end
        yield last if last != ""
      end
    end
  end
end
