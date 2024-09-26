# Tests:
#

class TableValue
  attr_reader :table
  attr_reader :value
  def initialize(table, any)
    @table = table
    @value = any
  end

  def set(new_value)
    @value = new_value
  end
end
