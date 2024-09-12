class Array
  def native_array_method?(name)
    respond_to?(name.to_sym) &&
      (!df_defined?(name) ||
       !df_get(name).is_a?(Fn))
  end
end
