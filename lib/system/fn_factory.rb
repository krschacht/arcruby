# Syntax for defining a function (i.e. array-proc):
#
# df_set(:concat, fn[:concat, [:a, :b], 'a + b' ]); reverse = fn[:reverse, [:a, :b], [:concat, :b, :a]]; reverse['x','y']
# df_set(:concat, fn[:concat, [:args], 'args.join' ]); same = fn[:same, [:args], [:concat, :args]]; same['x','y']
#
# concat = fn[:concat, [:a, :b], 'a + b' ]; concat['x','y']
# concat = fn[:concat, [:args],  'args.join' ]; concat['x','y','z']
#
# concat = fn[:concat, [:a, :b]] { _1 + _2 }; concat['x','y']
# concat = fn[:concat, [:args]]  { _1.join }; concat['x','y','z']
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
# TESTS:  TODO: Modify these tests to use argument names which potentially colide with things in fn
#
# blocks
#
# ~df[:greet, []] { "hello" }; greet[]                                                  # with no args
# => [#<:greet>]
# => `hello`
# ~df[:string, [:a, :b]] { _1 + _2 }; string['first', 'last']                           # with named args
# => [#<:string>, `first`, `last`]
# => `firstlast`
# ~df[:string, [:args]] { it.join }; string['first', 'middle', 'last']                  # with wildcard args
# => #<:string>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# ~df[:string, [:a, :args]] { "#{_1} then #{_2}" }; string['a', 'b', 'c']               # with named & wildcard args
# [#<:string>, `a`, `b`, `c`]
# => `a then [`b`, `c`]`
# ~df[:dotwicer, [:proc]] { _1[] + _1[] }; dotwicer[] { "Hello there" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `Hello thereHello there`
# ~df[:dotwicer, [:a, :proc]] { _2[_1] + _2[_1] }; dotwicer['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
# ~df[:dotwicer, [:args, :proc]] { puts "hi" }                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# ~df[:dotwicer, [:a, :proc, :b]] { puts "hi" }                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# ~df[:dotwicer, [:a, :args, :b]] { puts "hi" }                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#
# procs
#
# ~df[:greet, [], ->{ "hello" }]; greet[]                                                  # with no args
# => [#<:greet>]
# => `hello`
# ~df[:string, [:a, :b], ->{ _1 + _2 }]; string['first', 'last']                           # with named args
# => [#<:string>, `first`, `last`]
# => `firstlast`
# ~df[:string, [:args], ->{ it.join }]; string['first', 'middle', 'last']                  # with wildcard args
# => #<:string>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# ~df[:string, [:a, :args], ->{ "#{_1} then #{_2}" }]; string['a', 'b', 'c']               # with named & wildcard args
# [#<:string>, `a`, `b`, `c`]
# => `a then [`b`, `c`]`
# ~df[:dotwicer, [:proc], ->{ _1[] + _1[] }]; dotwicer[] { "Hello there" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `Hello thereHello there`
# ~df[:dotwicer, [:a, :proc], ->{ _2[_1] + _2[_1] }]; dotwicer['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
# ~df[:dotwicer, [:args, :proc], ->{ puts "hi" }]                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# ~df[:dotwicer, [:a, :proc, :b], ->{ puts "hi" }]                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# ~df[:dotwicer, [:a, :args, :b], ->{ puts "hi" }]                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#
# strings
#
# ~df[:greet, [], '"hello"' ]; greet[]                                                  # with no args
# => [#<:greet>]
# => `hello`
# ~df[:string, [:a, :b], 'a + b']; string['first', 'last']                           # with named args
# => [#<:string>, `first`, `last`]
# => `firstlast`
# ~df[:string, [:args], 'args.join']; string['first', 'middle', 'last']                  # with wildcard args
# => #<:string>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# ~df[:string, [:a, :args], 'a.inspect+" then "+args.inspect']; string['a', 'b', 'c']               # with named & wildcard args
# [#<:string>, `a`, `b`, `c`]
# => `a then [`b`, `c`]`
# ~df[:dotwicer, [:proc], 'proc[] + proc[]']; dotwicer[] { "Hello there" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `Hello thereHello there`
# ~df[:dotwicer, [:a, :proc], 'proc[a] + proc[a]' ]; dotwicer['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
# ~df[:dotwicer, [:args, :proc], 'puts "hi"' ]                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# ~df[:dotwicer, [:a, :proc, :b], 'puts "hi"' ]                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# ~df[:dotwicer, [:a, :args, :b], 'puts "hi"' ]                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#
#
# I think once I fix this then I confirm that all three forms can also be passed in when defining hello. Then keep testing the rest of array-procs, I'm about half way through it.

# array-procs
#
# ~df[:greet, [], '"hello"' ]; ~df[:hello, [], [greet]]; hello[]                                                                   # with no args
# => [#<:greet>]
# => `hello`
# ~df[:string, [:a, :b], 'a+b']; ~df[:flip, [:a, :b], [:string, :b, :a]]; flip['last', 'first']     # with named args
# => [#<:string>, `first`, `last`]
# => `firstlast`
# ~df[:string, [:args], 'args.join']; ~df[:merge, [:args], [:string, :args]]; merge['first', 'middle', 'last']                  # with wildcard args
# => #<:string>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# ~df[:string, [:args], 'args.join']; ~df[:formalize, [:a, :args], [:string, :args, :a]]; formalize['last', 'first', 'middle']
# => [#<:string>, `first`, `middle`, `last`]
# => `firstmiddlelast`
# ~df[:dotwicer, [:proc], 'proc[] + proc[]']; ~df[:doubler, [:proc], [:dotwicer, :proc]]; doubler[] { "Hello" }                 # with proc args
# => [#<:dotwicer>, #<Proc>]
# => `HelloHello`
# ~df[:dotwicer, [:a, :proc], 'proc[a] + proc[a]' ]; ~df[:doubler, [:a, :proc], [:dotwicer, :a, :proc]]; doubler['keith'] { "Hello #{it}" }  # with named & proc args
# => [#<:dotwicer>, `keith`, #<Proc>]
# => `Hello keithHello keith`
#

# ~df[:greet, [], '"hello"' ]; ~df[:dotwicer, [:args, :proc], [greet] ]                                          # not supported
# => RuntimeError: Using both :prc and :args in a method definition is not supported.
# ~df[:greet, [], '"hello"' ]; ~df[:dotwicer, [:a, :proc, :b], [greet] ]                                         # not supported
# => RuntimeError: When using :proc it must be the last parameter.
# ~df[:greet, [], '"hello"' ]; ~df[:dotwicer, [:a, :args, :b], [greet] ]                                         # not supported
# => RuntimeError: When using :args it must be the last parameter.
#

# TODO: Make fn work like this: ~[:fn, ...]

fn_proc = ->(name, vars, o = nil, &block) {
  # if name.is_a?(Array) # allow name to be left off for anonymous functions
  #   o = vars
  #   vars = name
  #   name = :anonymous
  # end
  if o.nil? && block.nil? # name is being left off so it's an anonymous function
    o = vars
    vars = name
    name = :anonymous
  end

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
    _vars = vars
    _block = block
    s = <<-RUBY
      Fn.new(name) { |*all|
        ->(#{args}) {
          _context = Class.new { def new_binding = binding }.new.new_binding
          $all_df_defined.each { |v, p| _context.local_variable_set(v, TOPLEVEL_BINDING.local_variable_get(v)) if !v.to_s.include?('?') && v != name }
          _vars.each_with_index do |v, i|
            if v == :args
              _context.local_variable_set(v, all[i..])
            else
              _context.local_variable_set(v, all[i])
            end
          end
          _block[*_vars.map { |v| _context.local_variable_get(v) }]
        }[*all]
      }
    RUBY
    eval(s)

  in String if block.nil?
    _vars = vars
    _o = o
    s = <<-RUBY
      Fn.new(name) { |*all|
        ->(#{args}) {
          _context = Class.new { def new_binding = binding }.new.new_binding
          $all_df_defined.each { |v, p| _context.local_variable_set(v, TOPLEVEL_BINDING.local_variable_get(v)) if !v.to_s.include?('?') && v != name }
          _vars.each_with_index do |v, i|
            if v == :args
              _context.local_variable_set(v, all[i..])
            else
              _context.local_variable_set(v, all[i])
            end
          end
          eval(_o, _context)
        }[*all]
      }
    RUBY
    eval(s)

  in [_fn, *_rest] # no guards needed because we did -o above to normalize the array-proc form
    raise "Invalid fn. The body of the method was an array but not an array-proc." if o.class != ArrayProc
    _vars = vars

    s = <<-RUBY
      _vars_substitute = ->(arr, context) { arr.map { |v| v.is_a?(Array) ? _vars_substitute[v, context] : (context.local_variables.include?(v) ? context.local_variable_get(v) : v) } }
      Fn.new(name) { |*all|
        ->(#{args}) {
          _context = Class.new { def new_binding = binding }.new.new_binding
          $all_df_defined.each { |v, p| _context.local_variable_set(v, TOPLEVEL_BINDING.local_variable_get(v)) if !v.to_s.include?('?') && v != name }
          _vars.each_with_index do |v, i|
            if v == :args
              _context.local_variable_set(v, all[i..])
            else
              _context.local_variable_set(v, all[i])
            end
          end
          ~[ _fn, *_vars_substitute[_rest, _context] ]
        }[*all]
      }
    RUBY
    eval(s)

  else
    binding.irb
    raise "Invalid fn. Accepted forms are fn[:concat, [:a,:b], [string, :a, :b]] or fn[:concat, [:a,:b], 'a + b'] or fn[:concat, [:a,:b]] { _1 + _2 }"
  end
}
df_set(:fn, fn_proc)
#local_variable_set(:fn, Df.new(:fn) { |*args| [:fn, *args] })
local_variable_set(:fn, fn_proc)
df_set(:valid_method_name?, fn[:valid_method_name?, [:name],      '!!(name.to_s =~ /\A[a-z_][a-zA-Z_0-9]*[!?=]?\z/)'])
df_set(:valid_variable_name?, fn[:valid_variable_name?, [:name],  '!!(name.to_s =~ /\A[a-z_][a-zA-Z_0-9]*\z/)']) # cannot end with !, ?, or =.
df_set(:is_keyword?, fn[:is_keyword?, [:name], '%w{__FILE__ __LINE__ alias and begin BEGIN break case class def defined? do else elsif end END ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield}.include? name'])
df_set(:full_method_set?, fn[:full_method_set, [:name]] {
    name = it
    local_variable_set(name, Df.new(name) { |*args| [name, *args] })

    # Array.unfreeze_method(name)
    # Array.class_eval do
    #   define_method(name) do
    #     [df_get(name), *self]
    #   end
    # end
    # Array.freeze_method(name)
})
#~df_get(:full_method_set)[:fn]

df_set(:df, fn[:df, [:names, :vars, :o, :proc]] {
  names = _1; vars = _2; o = _3; blk = _4
  names = Array(names).map(&:to_sym)
  names.each do |name|
    #raise "The name '#{name}' is a reserved word and cannot be declared as an Fn" if [].native_array_method?(name)
    df_set name, fn[name, vars, o, &blk]
    df_get(:full_method_set?)[name]  if df_get(:valid_variable_name?)[name] && ! df_get(:is_keyword?)[name] # && ! [].native_array_method?(name)
  end
  df_get(names.first)
}
)
local_variable_set(:df, Df.new(:df) { |*args| [:df, *args] })

#~df_get(:full_method_set)[:df]
