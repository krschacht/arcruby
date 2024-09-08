class Array
  def native_array_method?(name)
    respond_to?(name.to_sym) &&
      (!local_variable_defined?(name.to_sym) ||
       !local_variable_get(name.to_sym).is_a?(Fn))
  end
end
