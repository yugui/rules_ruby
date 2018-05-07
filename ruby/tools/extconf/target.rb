require 'shellwords'
require 'set'

module Extconf
  class Target
    def initialize(name, deps, commands, double_colon = false)
      @name = name
      @double_colon = double_colon
      @deps = deps
      @commands = commands
      @command_terminated = false
      terminate_command_list!
    end

    attr_reader :name, :double_colon, :deps, :commands
    alias double_colon? double_colon

    def add_commands(commands)
      if @command_terminated
        raise "Target #{name} already has commands set"
      end
      @commands += commands
      terminate_command_list!
    end

    def add_deps(commands)
      @deps |= commands
    end

    private
    def terminate_command_list!
      @command_terminated = !@double_colon unless @commands.empty?
    end
  end

  class TargetDefinition
    def initialize(raw_name, double_colon = false)
      @raw_name = raw_name
      @double_colon = double_colon
      @raw_deps = []
      @raw_commands = []
    end

    attr_reader :double_colon
    alias double_colon? double_colon

    def names(context)
      context.expand(@raw_name).split(/\s+/)
    end

    def deps(context)
      @raw_deps.map {|raw|
        context.expand(raw).split(/\s+/)
      }.flatten
    end

    def commands(context)
      @raw_commands.map {|raw|
        Shellwords.split(context.expand(raw))
      }
    end

    def add_raw_deps(deps)
      @raw_deps << deps
    end

    def add_raw_commands(commands)
      @raw_commands << commands
    end
  end
end
