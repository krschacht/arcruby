# Tests:
#
# FnN.new(nil, "tester") { "hello" }
# => RuntimeError: FnN.new was not given a proc that returns a 2-element array
#
# FnN.new(nil, "tester") { [] }
# => RuntimeError: FnN.new was not given a proc that returns a 2-element array
#
# FnN.new(nil, "tester") { [1,2] }
# => RuntimeError: FnN.new was given a proc array that was not a Proc followed by a name Symbol
#
# FnN.new(nil, "tester") { [1,:tester] }
# => RuntimeError: FnN.new was given a proc array that was not a Proc followed by a name Symbol
#
# FnN.new(nil, "tester") { [->{}, :tester] }
# => <:tester>
# => "tester"
# => nil

class FnN < Proc
  attr_reader :name
  attr_reader :fn

  def initialize(fn, name, &block)
    arr = block[]
    raise "FnN.new was not given a proc that returns a 2-element array" unless arr.is_a?(Array) && arr.length == 2
    raise "FnN.new was given a proc array that was not a Proc followed by a name Symbol" unless arr in [Proc, Symbol]
    super(&block)
    @fn = fn
    @name = name
  end

  def inspect
    "<:#{@name}>"
  end
end
