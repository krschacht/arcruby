module InstanceVariableSet
  def local_variable_set(variable, with_value)
    var_module = Module.new do
      define_method(variable.to_sym) do
        #puts "inside getter" + variable.to_sym.to_s
        TOPLEVEL_BINDING.local_variable_get(variable.to_sym)
      end

      define_method("#{variable}=") do |value|
        TOPLEVEL_BINDING.local_variable_set(variable.to_sym, value)
      end
    end

    extend var_module

    #instance_variable_set("@#{variable}", with_value)
    TOPLEVEL_BINDING.local_variable_set(variable.to_sym, with_value)
  end

  def local_variable_get(variable)
    #instance_variable_get("@#{variable}")
    TOPLEVEL_BINDING.local_variable_get(variable.to_sym)
  end
end

Object.include(InstanceVariableSet)
