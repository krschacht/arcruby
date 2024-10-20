class EnhancedEvalError < StandardError
  attr_reader :original_error, :eval_backtrace

  def initialize(original_error, eval_backtrace)
    @original_error = original_error
    @eval_backtrace = eval_backtrace
    super("#{original_error.class}: #{original_error.message}")
  end

  def backtrace
    (eval_backtrace + original_error.backtrace).uniq
  end
end

def custom_eval(code, binding = nil, filename = "(eval)", lineno = 1)
  caller_locations = caller_locations(1)
  eval(code, binding, filename, lineno)
rescue => e
  raise EnhancedEvalError.new(e, caller_locations.map(&:to_s))
end
