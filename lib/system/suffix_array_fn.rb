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

    [ method_get(method_name), *args]
  end

  private

  def args
    self.reduce([]) { |arr, a| arr += a.is_a?(Hash) ? Array(a).flatten : [a] }
  end
end

# TODO: Get suffix-array working maybe by having "fn" explictly declare an instance method on Array (and make sure it doesn't collide with anything) -- DONE!
# Test to make sure all the fn_factory things work
# Then see if I can get normal methods working too. This was ChatGPT's idea:

# module TesterModule
#   def self.tester(*args)
#     proc { args.inject(:*) }
#   end

#   def self.[](*args)
#     tester(*args).call
#   end

#   def self.method_missing(method_name, *args, &block)
#     if method_name == :tester
#       self[*args]
#     else
#       super
#     end
#   end

#   def self.respond_to_missing?(method_name, include_private = false)
#     method_name == :tester || super
#   end
# end
