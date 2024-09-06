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
# TESTS for -[]
#
# > fn[:greet, [], `"hello"` ]; -[greet]
# => [#<:greet>]
#
# > fn[:greet, [], `"hello"` ]; -[greet[].first]
# => [#<:greet>]
#
# > fn[:greet, [], `"hello"` ]; -[:greet]
# => [#<:greet>]
#
# > fn[:greet, [], `"hello"` ]; -%w[ :greet ]
# => [#<:greet>]
#
# > fn[:greet, [], `"hello"` ]; -[3]
# => RuntimeError: The first element of the array-proc was a Integer which is not a symbol or a proper fn.
#
# > fn[:greet, [], `"hello"` ]; -["greet"]
# => RuntimeError: The first element of the array-proc was a String which is not a symbol or a proper fn.
#
# > -[->{}]
# => RuntimeError: The array-proc first element is a proc which is not an fn: #<Proc>

# TESTS for ~[]
#
# > fn[:greet, [], `"hello"` ]; ~[greet]
# => "hello"
#
# > fn[:greet, [], `"hello"` ]; ~[greet[].first]
# => "hello"
#
# > fn[:greet, [], `"hello"` ]; ~[:greet]
# => "hello"
#
# > fn[:greet, [], `"hello"` ]; ~%w[ :greet ]
# => "hello"
#
# Error cases are already covered by -[]


class Array
  def -@ # normalizes the array-proc form to be [fn, ...]
    prc = self.first
    case prc
    in Proc
      if (prc[] rescue false) && (prc[] in [Proc, Symbol])
        self
      elsif (prc[] rescue false) && (prc[].is_a?(Array) && prc[].first.is_a?(Proc)) && (prc[].first[] in [Proc, Symbol])
        fn = prc[].first
        [fn, *remaining_args]
      else
        raise "The array-proc first element is a proc which is not an fn: #{prc.inspect}"
      end

    in Symbol | String => s if s.is_a?(Symbol) || s.start_with?(":")
      prc = method_get(prc)
      raise "The array-proc first element is a symbol that does not refer to a valid fn: :#{prc}" unless (prc[] rescue false) && (prc[].is_a?(Array) && prc[].first.is_a?(Proc)) && (prc[].first[] in [Proc, Symbol])
      fn = prc[].first
      [fn, *remaining_args]

    else
      raise "The first element of the array-proc was a #{prc.class} which is not a symbol or a proper fn."
    end
  end

  def ~
    (fn, *args) = -self
    fn[].first[*args]
  end

  private

  def remaining_args
    self.drop(1).reduce([]) { |arr, a| arr += a.is_a?(Hash) ? Array(a).flatten : [a] }
  end

  def method_get(variable)
    #eval("self", ROOT).instance_variable_get(variable.to_s.gsub(":", "@"))
    TOPLEVEL_BINDING.local_variable_get(variable.to_s.gsub(":", "").to_sym)
  end
end