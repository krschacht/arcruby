# Syntax for defining a function (i.e. array-proc):
#
# fn[:concat, [:a, :b], [string, :a, :b]]
# fn[:concat, [:args],  [string, :args]]
#
# fn[:concat, [:a, :b], `a + b` ]
# fn[:concat, [:args],  `args.join` ]
#
# fn[:concat, [:a, :b]] { _1 + _2 }
# fn[:concat, [:args]]  { args.join }
#
# Note:
#   args is a special argument name which is replaced with *args
#   proc is a special argument name which is replaced with &proc
#   named arguments (e.g. :a, :b) must be referenced by _1, _2, or 'it' with blocks
#
# All of this create a proc which returns the normal array-proc syntax:
#
#   > concat[ "first", "last" ]
#   => [ :string, "first", "last" ]
#   or
#   => [ #<Proc (lambda)> ]
#
# You should then execute this with an array-proc execution method.
#
# TESTS:
#
# blocks
#
# fn[:greet, []] { "hello" }; greet[]                                                  # with no args
# => [#<:greet>]
# => `hello`
# fn[:concat, [:a, :b]] { _1 + _2 }; concat['first', 'last']                           # with named args
# => [#<:concat>, `first`, `last`]
# => `firstlast`
# fn[:concat, [:args]] { it.join }; concat['first', 'middle', 'last']                  # with wildcard args
# => #<:concat>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# fn[:concat, [:a, :args]] { "#{_1} then #{_2}" }; concat['a', 'b', 'c']               # with named & wildcard args
# [#<:concat>, `a`, `b`, `c`]
# => `a then [`b`, `c`]`
# fn[:dotwicer, [:proc]] { _1[] + _1[] }; dotwicer[] { "Hello there" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `Hello thereHello there`
# fn[:dotwicer, [:a, :proc]] { _2[_1] + _2[_1] }; dotwicer['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
# fn[:dotwicer, [:args, :proc]] { puts "hi" }                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# fn[:dotwicer, [:a, :proc, :b]] { puts "hi" }                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# fn[:dotwicer, [:a, :args, :b]] { puts "hi" }                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#
# procs
#
# fn[:greet, [], ->{ "hello" }]; greet[]                                                  # with no args
# => [#<:greet>]
# => `hello`
# fn[:concat, [:a, :b], ->{ _1 + _2 }]; concat['first', 'last']                           # with named args
# => [#<:concat>, `first`, `last`]
# => `firstlast`
# fn[:concat, [:args], ->{ it.join }]; concat['first', 'middle', 'last']                  # with wildcard args
# => #<:concat>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# fn[:concat, [:a, :args], ->{ "#{_1} then #{_2}" }]; concat['a', 'b', 'c']               # with named & wildcard args
# [#<:concat>, `a`, `b`, `c`]
# => `a then [`b`, `c`]`
# fn[:dotwicer, [:proc], ->{ _1[] + _1[] }]; dotwicer[] { "Hello there" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `Hello thereHello there`
# fn[:dotwicer, [:a, :proc], ->{ _2[_1] + _2[_1] }]; dotwicer['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
# fn[:dotwicer, [:args, :proc], ->{ puts "hi" }]                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# fn[:dotwicer, [:a, :proc, :b], ->{ puts "hi" }]                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# fn[:dotwicer, [:a, :args, :b], ->{ puts "hi" }]                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#
# strings
#
# fn[:greet, [], `"hello"` ]; greet[]                                                  # with no args
# => [#<:greet>]
# => `hello`
# fn[:concat, [:a, :b], `a + b`]; concat['first', 'last']                           # with named args
# => [#<:concat>, `first`, `last`]
# => `firstlast`
# fn[:concat, [:args], `args.join`]; concat['first', 'middle', 'last']                  # with wildcard args
# => #<:concat>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# fn[:concat, [:a, :args], `a.inspect+" then "+args.inspect`]; concat['a', 'b', 'c']               # with named & wildcard args
# [#<:concat>, `a`, `b`, `c`]
# => `a then [`b`, `c`]`
# fn[:dotwicer, [:proc], `proc[] + proc[]`]; dotwicer[] { "Hello there" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `Hello thereHello there`
# fn[:dotwicer, [:a, :proc], `proc[a] + proc[a]` ]; dotwicer['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
# fn[:dotwicer, [:args, :proc], `puts "hi"` ]                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# fn[:dotwicer, [:a, :proc, :b], `puts "hi"` ]                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# fn[:dotwicer, [:a, :args, :b], `puts "hi"` ]                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#
#
# I think once I fix this then I confirm that all three forms can also be passed in when defining hello. Then keep testing the rest of array-procs, I'm about half way through it.

# array-procs
#
# fn[:greet, [], `"hello"` ]; fn[:hello, [], [greet]]; hello[]                                                                   # with no args
# => [#<:greet>]
# => `hello`
# fn[:concat, [:a, :b], `a+b`]; fn[:reverse, [:a, :b], [:concat, :b, :a]]; reverse['last', 'first']     # with named args
# => [#<:concat>, `first`, `last`]
# => `firstlast`
# fn[:concat, [:args], `args.join`]; fn[:merge, [:args], [:concat, :args]]; merge['first', 'middle', 'last']                  # with wildcard args
# => #<:concat>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# fn[:concat, [:args], `args.join`]; fn[:formalize, [:a, :args], [:concat, :args, :a]]; formalize['last', 'first', 'middle']
# => [#<:concat>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# fn[:dotwicer, [:proc], `proc[] + proc[]`]; fn[:doubler, [:proc], [:dotwicer, :proc]]; doubler[] { "Hello" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `HelloHello`
# fn[:dotwicer, [:a, :proc], `proc[a] + proc[a]` ]; fn[:doubler, [:a, :proc], [:dotwicer, :a, :proc]]; doubler['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
#

# fn[:greet, [], `"hello"` ]; fn[:dotwicer, [:args, :proc], [greet] ]                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# fn[:greet, [], `"hello"` ]; fn[:dotwicer, [:a, :proc, :b], [greet] ]                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# fn[:greet, [], `"hello"` ]; fn[:dotwicer, [:a, :args, :b], [greet] ]                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#

fn = ->(name, vars, o = nil, &block) {
  name = name.to_sym

  raise "The name '#{name}' is a reserved word and cannot be declared as an Fn" if [].respond_to?(name)
  vars = Array(vars)
  var_list = vars.map { |v| v = v.to_s; if v == "args" then "*args" else v end }.join(',')
  raise ArgumentError, "The second element must be a symbol or an array of symbols:  fn[:func, [:a, :b], ...]" unless vars.all? { |v| v.is_a?(Symbol) }
  args = vars.map { |v| v = v.to_s; if v == "args" then "*args" elsif v == "proc" then "&proc" else v end }.join(',')

  if o.is_a?(Proc)
    block = o
    o = nil
  end

  o = -o if o.is_a?(Array)

  raise "Using both :prc and :args in a method definition is not supported." if vars.include?(:args) && vars.include?(:proc)
  raise "When using :args it must be the last parameter." if vars.include?(:args) && vars.index(:args) != vars.length-1
  raise "When using :proc it must be the last parameter." if vars.include?(:proc) && vars.index(:proc) != vars.length-1

  case o # create a proc which looks like a method call but it simply returns the proper array-proc form

  in nil unless block.nil?
    f = Fn.new(name) { |*all, &prc|
      all.push(prc) unless prc.nil?

      [ ->{
        [
          ->(*all) {
            local_binding = binding
            vars.each_with_index do |v, i|
              if v == :args
                local_binding.local_variable_set(v, all[i..])
              else
                local_binding.local_variable_set(v, all[i])
              end
            end

            block[*vars.map { |v| local_binding.local_variable_get(v) }]
          },
          name
        ]},
        *all
      ]
    }
    local_variable_set(name, f)

    Array.class_eval do
      define_method(name) do
        [local_variable_get(name), *self]
      end
    end

  in String if block.nil?
    f_str = <<-RUBY
      Fn.new(name) { |*all, &prc|
        all.push(prc) unless prc.nil?

        [ ->{
          [ ->(*all) {
            local_binding = binding
            vars.each_with_index do |v, i|
              if v == :args
                local_binding.local_variable_set(v, all[i..])
              else
                local_binding.local_variable_set(v, all[i])
              end
            end

            eval(o, local_binding) },
            name
          ]},
          *all
        ]
      }
    RUBY
    local_variable_set(name, eval(f_str))

    Array.class_eval do
      define_method(name) do
        [local_variable_get(name), *self]
      end
    end

  in [fn, *rest] # no guards needed because we did -o above to normalize the array-proc form
    f = Fn.new(name) { |*all, &prc|
      all.push(prc) unless prc.nil?

      local_binding = binding
      vars.each_with_index do |v, i|
        if v == :args
          local_binding.local_variable_set(v, all[i..])
        else
          local_binding.local_variable_set(v, all[i])
        end
      end

      [ fn, *rest.map { |v| local_binding.local_variable_get(v) }.flatten ]
    }
    local_variable_set(name, f)

    Array.class_eval do
      define_method(name) do
        [local_variable_get(name), *self]
      end
    end

  else
    raise "Invalid fn. Accepted forms are fn[:concat, [:a,:b], [string, :a, :b]] or fn[:concat, [:a,:b], 'a + b'] or fn[:concat, [:a,:b]] { _1 + _2 }"
  end
}

local_variable_set(:fn, fn)
