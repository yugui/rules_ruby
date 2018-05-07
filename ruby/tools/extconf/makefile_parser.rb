require_relative 'variable'
require_relative 'target'

module Extconf
  # An insufficient and inefficient parser of Makefile,
  # which is, however good enough to deal with Makefiles
  # mkmf generates.
  class MakefileParser
    def initialize(io)
      @io = io
    end

    def parse
      context = Context.new
      target_defs = []
      last_target = nil
      each_line do |line|
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
      context.each_variable do |name, var|
        puts "#{name} = #{var.evaluate(context)}"
      end

      targets = {}
      target_defs.each do |t|
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

      targets.each do |name, target|
        p target
      end
    end

    private

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

if $0 == __FILE__
  Extconf::MakefileParser.new($<).parse
end
