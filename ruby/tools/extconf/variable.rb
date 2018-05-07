require_relative 'context'

module Extconf
  class Variable
    def initialize(name, definition)
      @name = name
      @definition = definition
    end

    def evaluate(context)
      context.expand(@definition)
    end
  end
end

