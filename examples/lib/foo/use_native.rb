require 'json'
require 'jsonnet'

module Foo
  module UseNative
    module_function
    def jsonnet_version
      code = <<-EOS
        local base = {
          hello: 'jsonnet',
        };

        function(version) base {
          "version": version,
        }
      EOS

      vm = Jsonnet::VM.new
      vm.tla_var('version', Jsonnet::VERSION)

      JSON.parse(vm.evaluate(code))
    end
  end
end
