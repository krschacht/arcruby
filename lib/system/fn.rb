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
# string = ->(a,b) { a+b }; fn[:concat, [:a, :b], [ string, :a, :b ] ]
# => RuntimeError: The body of the fn includes a proc which is not an fn. The proc in here: [#<Proc>, :a, :b]
# fn[:string, [:a, :b]] { _1 + _2 }; fn[:concat, [:a, :b], [ string, :a, :b ] ]; concat[ "first", "last" ]
# => [#<Proc>, "first", "last"]
# string = -> { [-> (*args) { args.join }, :string ] }; local_variable_set(:string, string); fn[:concat, [:args], [ string, :args ] ]; concat[ "first", "middle", "last" ]
# => [:string, "first", "middle", "last"]
# => "firstmiddlelast"
# apply = -> { [-> (a,&proc) { proc[a] + proc[a] }, :apply ] }; local_variable_set(:apply, apply); fn[:dotwice, [:a, :proc], [ apply, :a, :proc ] ]; dotwice['keith'] { "Hello #{it}" }
# => "Hello keithHello keith"
# hello = -> { [-> { puts "hello" }, :hello ] }; local_variable_set(:hello, hello); fn[:greet, [], [hello]]
# => "hello"
#
# fn[:concat, [:a, :b], `a + b` ]; concat['first', 'last']
# => [#<Proc>, "first", "last"]
# fn[:greet], [], `puts "hello"`]
#=> "hello"
# fn[:concat, [:args], `args.join` ]; concat['first', 'middle', 'last']
# => [#<Proc>, "first", "middle", "last"]
# => "firstmiddlelast"
# fn[:dotwicer, [:a, :proc], `proc[a] + proc[a]` ]; dotwicer['keith'] { "Hello #{it}" }
# => [#<Proc>, "keith", #<Proc>]
# => "Hello keithHello keith"
#
# fn[:concat, [:a, :b]] { _1 + _2 }; concat['first', 'last']
# => [#<Proc>, "first", "last"]
# fn[:greet, []] { puts "hello" }; greet[]
#=> "hello"
# fn[:concat, [:args]] { it.join }; concat['first', 'middle', 'last']
# => [#<Proc>, "first", "middle", "last"]
# => "firstmiddlelast"
# fn[:dotwicer, [:a, :proc]] { proc[a] + proc[a] }; dotwicer['keith'] { "Hello #{it}" }
# => [#<Proc>, "keith", #<Proc>]
# => "Hello keithHello keith"
#
# fn[:concat, [:a, :b], ->{ _1 + _2 }]; concat['first', 'middle']
# => [#<Proc>, "first", "middle"]




# what about when args is not the ONLY param but it's one of the params?

fn = ->(name, vars, o = nil, &block) {
  name = name.to_sym
  vars = Array(vars)
  var_list = vars.map { |v| v = v.to_s; if v == "args" then "*args" else v end }.join(',')
  raise ArgumentError, "The second element must be a symbol or an array of symbols:  fn[:func, [:a, :b], ...]" unless vars.all? { |v| v.is_a?(Symbol) }
  args = vars.map { |v| v = v.to_s; if v == "args" then "*args" elsif v == "proc" then "&proc" else v end }.join(',')

  if o.is_a?(Proc)
    block = o
    o = nil
  end

  case o # create a proc which looks like a method call but it simply returns the proper array-proc form
  in [prc, *rest] if prc.is_a?(Proc)
    raise "The body of the fn includes a proc which is not an fn. The proc in here: #{o.inspect}" unless prc[] in [Proc, *ignore] && (prc[].first[] rescue false) && (func[].first[] in [Proc, Symbol])
    func = prc[].first
    local_variable_set(name, ->(*all) {
      local_binding = binding
      vars.each_with_index do |v, i|
        local_binding.local_variable_set(v, all[i])
      end

      [ [ func, *rest.map { |v| local_binding.local_variable_get(v) } ], name ]
    })
  in String
    local_variable_set(name, eval("->(#{args}) { [ ->{ [ ->(#{args}) { #{o} }, :anonymous ] }, #{var_list} ] }"))
  in nil
    raise "When defining a function without specifying the body, a block is expected:  fn[:func, [:a, :b]] { ... }" if block.nil?
    if vars.map(&:to_s).include?("args")
      local_variable_set(name, ->(*all) { [ ->{ [ ->(*all) { block[all] }, :anonymous ] }, *all ] })
    else
      local_variable_set(name, ->(*all) { [ ->{ [ ->(*all) { block[*all] }, :anonymous ] }, *all ] })
    end
  else
    raise "No valid form of fn was called"
  end
}

local_variable_set(:fn, fn)
