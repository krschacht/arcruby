# Tests:
#

class TableValue

  def initialize(key, any)
    @key = key
    @value = any
  end

  def _(new_value)
    @value = new_value
    self
  end

  def __
    @key
  end

  def method_missing(method_name, *arguments, &block)
    @value[method_name]
  end

  def inspect
    "[#{@key.inspect}]#{@value}"
  end
end
