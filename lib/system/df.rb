# Tests:
#
# test = Df.new(:test) { |*args| [:test, *args] }
# > test[1,2,3]
# => [:test, 1,2,3]
#
# test = Df.new("test") { |*args| [:test, *args] }
# => Df.new was not given a symbol for a name (RuntimeError
#
# test = Df.new { |*args| [:test, *args] }
# => wrong number of arguments (given 0, expected 1) (ArgumentError)
#
# test = Df.new(:test)
# => tried to create Proc object without a block (ArgumentError)

class Df < Proc
  attr_reader :name

  def initialize(name, &block)
    raise "Df.new was not given a symbol for a name" unless name.is_a?(Symbol)
    raise "Df.new was not given a symbol for a name" unless block_given?
    @name = name
    @block = block
    super(&block)
  end

  def call(*all, &prc)
    @block.call(*all, &prc)
  end

  def []( *all, &prc)
    call(*all, &prc)
  end

  def inspect
    "::#{@name}"
  end
end
