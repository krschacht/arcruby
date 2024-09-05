module Kernel
  alias_method :original_backticks, :`

  def `(str)
    # Escape double quotes within the string
    str = str.gsub(/'/, "\'")

    # Evaluate the string within the current context
    eval("'#{str}'", binding, __FILE__, __LINE__)
  end
end

class String
  alias_method :original_inspect, :inspect

  def inspect
    "`#{self}`"
  end
end