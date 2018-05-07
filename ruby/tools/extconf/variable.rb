module Extconf
  class Variable
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
    def initialize(name, definition)
      @name = name
      @definition = definition
    end

    def evaluate(context)
      @definition.gsub(VARIABLE_EXPR) do
        m = $~
        if m[:simple_name]
          var = context[m[:simple_name]]
          next var ? var.evaulate(context) : ''
        end

        var = context[m[:paren_name]]
        next '' unless var

        value = var.evaluate(context)
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

