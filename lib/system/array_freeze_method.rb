# This ensures that another ruby library (e.g. rails) does not override a Fn method.
#
# Tests:
#
# Array.class_eval do; define_method(:testing) { puts "First" }; end; [].testing
# => "First"
#
# Array.class_eval do; define_method(:testing) { puts "Second" }; end; [].testing
# => "Second"
#
# Array.freeze_method(:testing); [].testing
# => "Second"
#
# Array.class_eval do; define_method(:testing) { puts "Third" }; end
# => RuntimeError: Frozen method 'testing' cannot be modified without unfreezing first
#
# [].testing
# => "Second"
#
# Array.unfreeze_method(:testing); [].testing
# => "Second"
#
# Array.class_eval do; define_method(:testing) { puts "Third" }; end; [].testing
# => "Third"

class Array
  @@frozen_methods = {}

  def self.method_added(method_name)
    return if @adding_method

    if @@frozen_methods.key?(method_name)
      original_method = @@frozen_methods[method_name]
      @adding_method = true
      define_method(method_name, original_method)
      @adding_method = false
      raise "Frozen method '#{method_name}' cannot be modified without unfreezing first"
    end
  end

  def self.freeze_method(method_name)
    @@frozen_methods[method_name] = instance_method(method_name)
  end

  def self.unfreeze_method(method_name)
    @@frozen_methods.delete(method_name)
  end
end
