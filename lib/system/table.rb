# Tests:
#

class Table < Hash
  def initialize(*args)
    super(*args)
  end

  def self.[](*args)
    table = new
    args.each do |arg|
      arg.each do |key, value|
        table[key] = TableValue.new(key, value)
      end
    end
    table
  end

  def [](key)
    return self[key] = TableValue.new(key, nil) unless key?(key)
    super
  end
end
