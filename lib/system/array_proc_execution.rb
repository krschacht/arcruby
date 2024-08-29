# Syntax for executing an array as if it's a proc:
#
# ~[ func, arg1, arg2, ... ]
# ~[ :func, arg1, arg2, ... ]
# ~%w[ :func arg1 arg2 ... ]
# ~[ func ]
# -[ :func, arg1, arg2, ... ]
# -%w[ :func arg1 arg2 ... ]
# -[ func, arg1, arg2, ... ]
# -[ func ]
#
# TESTS:
#
# ~[ ->{ [ ->(a) { puts "hello #{a}" }, :greet ] }, 'keith' ]
# ~[ ->{ [ ->{ puts "hello keith" }, :greet ] } ]
# greet = ->{ [ ->(a) { puts "hello #{a}" }, :greet ] }; local_variable_set(:greet, greet); ~[ :greet, 'keith' ]
# greet = ->{ [ ->{ puts "hello keith" }, :greet ] };    local_variable_set(:greet, greet); ~[ :greet ]
#
# TEST ERRORS:
#
# ~[ ->{}, 'keith' ]
# => RuntimeError: The array-proc first element is a proc which is not an fn: #<Proc:0x000000011eef9d08 (pry):4 (lambda)>
# ~[ :greets, 'keith' ]
# => RuntimeError: The array-proc first element is a symbol that does not refer to a valid fn: :greets
# ~[ ":greets", 'keith' ]
# => RuntimeError: The array-proc first element is a symbol that does not refer to a valid fn: :greets
# ~[ [], 'keith' ]
# => RuntimeError: The first element of the array-proc was a #{f.class} which is not a symbol or a proc.

ROOT = binding

class Array
  def ~
    run_array
  end

  def -@
    run_array
  end

  private

  def run_array
    fn = self.first
    case fn
    in Proc
      raise "The array-proc first element is a proc which is not an fn: #{fn.inspect}" unless (fn[] rescue false) && (fn[] in [Proc, Symbol])
      prc = fn[].first
      prc[*remaining_args]

    in Symbol
      true_fn = global_variable_get("@#{fn}")
      raise "The array-proc first element is a symbol that does not refer to a valid fn: :#{fn}" unless (true_fn[] rescue false) && (true_fn[] in [Proc, Symbol])
      prc = true_fn[].first
      prc[*remaining_args]

    in String if fn.to_s.start_with?(':')
      true_fn = global_variable_get(fn.sub(':', '@'))
      raise "The array-proc first element is a symbol that does not refer to a valid fn: #{fn}" unless (true_fn[] rescue false) && (true_fn[] in [Proc, Symbol])
      prc = true_fn[].first
      prc[*remaining_args]

    else
      raise "The first element of the array-proc was a #{fn.class} which is not a symbol or a proc."
    end
  end

  def remaining_args
    self.drop(1).reduce([]) { |arr, a| arr += a.is_a?(Hash) ? Array(a).flatten : [a] }
  end

  def global_variable_get(variable)
    eval("self", ROOT).instance_variable_get(variable.to_s.gsub(":", "@"))
  end
end