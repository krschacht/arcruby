module LocalVariableSet
  def local_variable_set(variable, value)
    var_module = Module.new do
      define_method(variable.to_sym) do
        TOPLEVEL_BINDING.local_variable_get(variable.to_sym)
      end

      define_method("#{variable}=") do |value|
        TOPLEVEL_BINDING.local_variable_set(variable.to_sym, value)
      end
    end

    extend var_module
    TOPLEVEL_BINDING.local_variable_set(variable.to_sym, value)
  end

  def local_variable_get(variable)
    TOPLEVEL_BINDING.local_variable_get(variable.to_sym) rescue nil
  end

  def local_variable_defined?(variable)
    !!(TOPLEVEL_BINDING.local_variable_get(variable.to_sym) rescue false)
  end
end

Object.include(LocalVariableSet)



# More advanced version of local_variable_set
#
# module LocalVariableSet
#   def local_variable_set(variable, with_value = nil)
#     ivar_name = caller_locations(1,1)[0].label.gsub('<top (required)>', 'top_required').gsub('#', '_') + '_' + variable.to_s
#     var_module = Module.new do
#       define_method(variable.to_sym) do
#         ivar_name = caller_locations(1,1)[0].label.gsub('<top (required)>', 'top_required').gsub('#', '_') + '_' + variable.to_s

#         if !instance_variable_defined?("@#{ivar_name}")
#           calling_method = caller_locations(1,1)[0].label.gsub('<top (required)>', 'main')
#           error_message = "undefined local variable or method '#{variable}' for #{calling_method}"
#           e = NameError.new(error_message)
#           e.set_backtrace(caller(1))
#           raise e
#         end
#         instance_variable_get("@#{ivar_name}")
#       end

#       define_method("#{variable}=") do |value|
#         ivar_name = caller_locations(1,1)[0].label.gsub('<top (required)>', 'top_required').gsub('#', '_') + '_' + variable.to_s
#         instance_variable_set("@#{ivar_name}", value)
#       end
#     end

#     extend var_module
#     eval("@#{ivar_name}=#{with_value}")
#   end
# end
# include LocalVariableSet