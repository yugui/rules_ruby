require_relative 'variable'

module Extconf
  # An insufficient and inefficient parser of Makefile,
  # which is, however good enough to deal with Makefiles
  # mkmf generates.
  class MakefileParser
    def initialize(io)
      @io = io
    end

    def parse
      context = {}
      each_line do |line|
        if line[/^([[:alpha:]][[:alnum:]_]*)\s*=\s*(.*)/]
          context[$1] = Variable.new($1, $2)
        end
      end
      context.each do |name, var|
        puts "#{name} = #{var.evaluate(context)}"
      end
    end

    private

    def each_line
      last = ""
      @io.each_line do |line|
        last += line
        if line.end_with?('\\')
          last[-1] = ' '
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
