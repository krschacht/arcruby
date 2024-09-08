# Tests:
#
# Fn.new("tester") { "hello" }
# => RuntimeError: Fn.new was not given a proc that returns a valid array
#
# Fn.new("tester") { [] }
# => RuntimeError: Fn.new was not given a proc that returns a valid array
#
# Fn.new("tester") { [1] }
# => RuntimeError: Fn.new was not given a proc array that contains a valid FnN as the first element
#
# Fn.new("tester") { [->{}] }
# => RuntimeError: FnN.new was not given a proc that returns a 2-element array
#
# Fn.new("tester") { [->{ [ ->{}, :tester ]}] }
# => <:tester>
# => "tester"
# => <:tester>

class Fn < Proc
  attr_reader :name
  attr_reader :fn_n

  def initialize(name, &block)
    arr = block[]
    raise "Fn.new was not given a proc that returns a valid array" unless arr.is_a?(Array) && arr.length >= 1
    raise "Fn.new was not given a proc array that contains a valid FnN as the first element" unless arr in [Proc, *rest]

    @name = name
    @fn_n = FnN.new(self, name, &arr.first)
    arr[0] = @fn_n

    @block = ->(*args, &prc) { arr }
  end

  def call(*args, &prc)
    @block.call(*args, &prc)
  end

  def []( *args, &prc)
    call(*args, &prc)
  end

  def inspect
    "<:#{@name}>"
  end
end
