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
# greet = Fn.new("greet") { [->{ [ ->{ "hello" }, :greet ]}] }; df_set(:greet, greet)
#
# -[greet]
# => [#<:greet>]
#
# -[greet.fn_n]
# => [#<:greet>]
#
# -[:greet]
# => [#<:greet>]
#
# -%w[ :greet ]
# => [#<:greet>]
#
# -[3]
# => RuntimeError: The first element of the array-proc was a Integer which is not a symbol or a proper fn.
#
# -["greet"]
# => RuntimeError: The first element of the array-proc was a String which is not a symbol or a proper fn.
#
# -[->{}]
# => RuntimeError: The array-proc first element is a proc which is not an fn: #<Proc>

# TESTS for ~[]
#
# ~[greet]
# => "hello"
#
# ~[greet.fn_n]
# => "hello"
#
# ~[:greet]
# => "hello"
#
# ~%w[ :greet ]
# => "hello"
#
# Error cases are already covered by -[]


class Array
  def -@ # normalizes the array-proc form to be [fn, ...]
    elem = self.first
    case elem
    in FnN
      self
    in Fn
      [elem.fn_n, *remaining_args]
      #[elem, *remaining_args]
      # if (prc[] rescue false) && (prc[] in [Proc, Symbol])
      #   self
      # elsif (prc[] rescue false) && (prc[].is_a?(Array) && prc[].first.is_a?(Proc)) && (prc[].first[] in [Proc, Symbol])
      #   fn = prc[].first
      #   [fn, *remaining_args]
      # else
      #   raise "The array-proc first element is a proc which is not an fn: #{prc.inspect}"
      # end

    in Symbol | String => s if s.is_a?(Symbol) || s.start_with?(":")
      fn = method_get(elem)
      raise "The array-proc first element is a symbol that does not refer to a valid fn: :#{fn}" unless fn.is_a?(Fn) # (prc[] rescue false) && (prc[].is_a?(Array) && prc[].first.is_a?(Proc)) && (prc[].first[] in [Proc, Symbol])
      [fn.fn_n, *remaining_args]

    else
      raise "The first element of the array-proc was a #{elem.class} which is not a symbol or a proper fn."
    end
  end

  def ~
    (fn_n, *args) = -self
    fn_n.proc[*args]
  end

  private

  def remaining_args
    self.drop(1).reduce([]) { |arr, a| arr += a.is_a?(Hash) ? Array(a).flatten : [a] }
  end

  def method_get(variable)
    df_get(variable.to_s.gsub(":", "").to_sym)
  end
end