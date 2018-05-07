require_relative 'variable'

module Extconf
  class Context
    VARIABLE_EXPR = %r<
        (?!\\)
        \$(?:
            (?<simple_name>[[:alpha:]][[:alnum:]_]*)
          | \(
              (?<paren_name>[[:alpha:]][[:alnum:]_]*)
              (?:
               :(?<replace_name>[^=]+)=(?<replace_value>[^\)]*)
              )?
            \)
         )
    >x

    def initialize
      @variables = {}
    end

    def each_variable
      @variables.each do |name, variable|
        yield name, variable
      end
    end

    def set_variable(name, definition)
      @variables[name] = Variable.new(name, definition)
    end

    def expand(str)
      str.gsub(VARIABLE_EXPR) do
        m = $~
        if m[:simple_name]
          var = @variables[m[:simple_name]]
          next var ? var.evaulate(self) : ''
        end

        var = @variables[m[:paren_name]]
        next '' unless var

        value = var.evaluate(self)
        if m[:replace_name]
          # m[:replace_value] does not contain variable references
          # because BSD make on Solaris does not support it unlike GNU Make.
          value.gsub(m[:replace_name], m[:replace_value])
        else
          value
        end
      end
    end
  end
end
