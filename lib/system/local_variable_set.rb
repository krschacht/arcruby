module LocalVariableSet
  def local_variable_set(variable, with_value = nil)
    var_module = Module.new do
      define_method(variable.to_sym) do
        TOPLEVEL_BINDING.local_variable_get(variable.to_sym)
      end

      define_method("#{variable}=") do |value|
        TOPLEVEL_BINDING.local_variable_set(variable.to_sym, value)
      end
    end

    extend var_module
    with_value ||= df_get(variable.to_sym)
    TOPLEVEL_BINDING.local_variable_set(variable.to_sym, with_value)
  end

  def local_variable_get(variable)
    TOPLEVEL_BINDING.local_variable_get(variable.to_sym) rescue nil
  end

  def local_variable_defined?(variable)
    !!(TOPLEVEL_BINDING.local_variable_get(variable.to_sym) rescue false)
  end
end

Object.include(LocalVariableSet)
