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
# greet = Fn.new("greet") { [->{ [ ->{ "hello" }, :greet ]}] }; fn_set(:greet, greet)
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
      if (fn.is_a?(Fn) || fn.is_a?(MacFn))
        [fn, *remaining_args]
      else
        self
      end

    in Symbol | String => s if s.is_a?(Symbol) || s.start_with?(":")
      fn = method_get(elem)
      if (fn.is_a?(Fn) || fn.is_a?(MacFn))
        [fn, *remaining_args]
      else
        self
      end
    in Array => e if e.is_a?(ArrayProc)  # I cannot get a simple "in ArrayProc" to work
      [~elem, *remaining_args]
    else
      self
    end
  end

  def ~
    (first_elem, *args) = -self

    if first_elem.is_a?(Fn) || first_elem.is_a?(MacFn)
      execute_fn(first_elem, args)
    elsif first_elem.class == ArrayProc
      execute_fn(method_get(:progn), [[first_elem, *args]])
    elsif first_elem.is_a?(Table)
      execute_table(first_elem, args.first)
    else
      raise "The first element of array-proc was a #{first_elem.class} which is not a symbol, proper fn, list of array-procs, or a table."
    end
  end

  def class
    if length >= 1 && [Fn, MacFn, Table].include?((-self).first.class) # the first element of -[] is either Fn or Table
      ArrayProc
    else
      super
    end
  end

  alias_method :original_instance_of?, :instance_of?
  def instance_of?(klass)
    klass == ArrayProc ? self.class == ArrayProc : original_instance_of?(klass)
  end

  alias_method :original_kind_of?, :kind_of?
  def kind_of?(klass)
    klass == ArrayProc ? self.class <= ArrayProc : original_kind_of?(klass)
  end

  alias_method :original_is_a?, :is_a?
  def is_a?(klass)
    klass == ArrayProc ? self.class <= ArrayProc : original_is_a?(klass)
  end

  alias_method :original_triple_equal, :===
  def ===(other)
    self.is_a?(ArrayProc) || original_triple_equal(other)
  end

  def fn
    if (the_fn = (-self).first).is_a?(Fn)
      the_fn
    else
      nil
    end
  end

  private

  def execute_fn(fn, args)
    if fn.name != :df && fn.name != :mac && fn.name != :fn && fn.name != :mac_fn && fn.class != MacFn
      args = args.map { |a| a.class == ArrayProc ? ~a : a }
    end
    fn[*args]
  end

  def execute_table(table, key)
    table[key.class == ArrayProc ? ~key : key]
  end

  def remaining_args
    self.drop(1).reduce([]) { |arr, a| arr += a.is_a?(Hash) ? Array(a).flatten : [a] }
  end

  def method_get(variable)
    fn_get(variable.to_s.gsub(":", "").to_sym)
  end
end
