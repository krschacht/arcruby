class Array
  def native_array_method?(name)
    is_a_fn = (arr = send(name)).is_a?(Array) && arr.first.is_a?(Fn) rescue false
    respond_to?(name.to_sym) && !is_a_fn
  end
end
