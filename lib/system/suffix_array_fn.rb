ROOT = binding

class Array
  EXCLUDED_METHODS = [
    :to_hash, :to_a, :to_s, :to_str, :inspect, :==, :eql?, :hash, :class, :singleton_class, :method, :methods,
    :instance_variable_get, :instance_variable_set, :instance_variables, :instance_variable_defined?,
    :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?,
    :extend, :freeze, :frozen?, :object_id, :define_singleton_method, :equal?, :!, :!=, :__send__, :__id__,
    :readline, :readlines, :gets, :get_input
  ]

  def method_missing(method_name, *arguments, &block)
    return super if EXCLUDED_METHODS.include?(method_name)

    [ global_variable_get(method_name), *args]
  end

  private

  def args
    self.reduce([]) { |arr, a| arr += a.is_a?(Hash) ? Array(a).flatten : [a] }
  end
end