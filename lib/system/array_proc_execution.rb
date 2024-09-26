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

class ArrayProc < Array; end

class Array
  def -@ # normalizes the array-proc form to be [fn, ...]
    elem = self.first
    case elem
    in FnN
      raise "The first element of array-proc was a FnN. That should not ever happen."
    in Fn
      [elem, *remaining_args]

    in Df
      fn = method_get(elem.name)
      if (fn.is_a?(Fn))
        [fn, *remaining_args]
      else
        self
      end

    in Symbol | String => s if s.is_a?(Symbol) || s.start_with?(":")
      fn = method_get(elem)
      if (fn.is_a?(Fn))
        [fn, *remaining_args]
      else
        self
      end
    else
      self
    end
  end

  def ~
    (fn_or_table, *args) = -self

    if fn_or_table.is_a?(Fn)
      execute_fn(fn_or_table, args)
    elsif fn_or_table.is_a?(Table)
      execute_table(fn_or_table, args.first)
    else
      raise "The first element of the array-proc was a #{fn_or_table.class} which is not a symbol or a proper fn or a table."
    end
  end

  def class
    if length >= 1 && [Fn, Table].include?((-self).first.class)
      ArrayProc
    else
      super
    end
  end

  private

  def execute_fn(fn, args)
    if fn.name == :df || fn.name == :fn || fn.name == :each || %w[if unless].include?(fn.name.to_s.split('_').first)
      args = args[0...-1].map { |a| a.class == ArrayProc ? ~a : a } << args.last
    else
      args = args.map { |a| a.class == ArrayProc ? ~a : a }
    end
    fn[*args]
  end

  def execute_table(table, key)
    table[key]
  end

  def remaining_args
    self.drop(1).reduce([]) { |arr, a| arr += a.is_a?(Hash) ? Array(a).flatten : [a] }
  end

  def method_get(variable)
    df_get(variable.to_s.gsub(":", "").to_sym)
  end
end
