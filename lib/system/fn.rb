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

  def initialize(name, &block)
    # arr = block[]
    # raise "Fn.new was not given a proc that returns a valid array" unless arr.is_a?(Array) && arr.length >= 1
    # raise "Fn.new was not given a proc array that contains a valid FnN as the first element" unless arr in [Proc, *rest]

    @name = name
    @block = block
    # @fn_n = if arr.first.is_a?(FnN)
    #   arr.first
    # else
    #    FnN.new(name, &arr.first)
    # end
    #@fn_n = FnN.new(name, &arr.first)

    # arr[0] = @fn_n

    # @block = block
  end

  def call(*all, &prc)
    begin
      @block.call(*all, &prc)
    rescue ArgumentError => e
      raise "You called #{name} incorrectly: #{e.message}"
    end
  end

  def []( *all, &prc)
    call(*all, &prc)
  end

  def inspect
    "<:#{@name}>"
  end
end
