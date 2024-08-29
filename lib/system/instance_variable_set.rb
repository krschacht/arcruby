module InstanceVariableSet
  def local_variable_set(variable, with_value)
    var_module = Module.new do
      attr_accessor variable.to_sym
    end

    extend var_module

    instance_variable_set("@#{variable}", with_value)
  end
end

Object.include(InstanceVariableSet)
