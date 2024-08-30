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
# string = -> (a,b) { a + b }; local_variable_set(:string, string);                   fn[:concat, [:a, :b], [ string, :a, :b ] ]; concat[ "first", "last" ]
# => RuntimeError: The body of the fn includes a proc which is not an fn. The proc in here: [#<Proc>, :a, :b]
# string = -> { [-> (a,b) { a + b }, :string ] }; local_variable_set(:string, string); fn[:concat, [:a, :b], [ string, :a, :b ] ]; concat[ "first", "last" ]
# => [:string, "first", "last"]
# string = -> { [-> (*args) { args.join }, :string ] }; local_variable_set(:string, string); fn[:concat, [:args], [ string, :args ] ]; concat[ "first", "middle", "last" ]
# => [:string, "first", "middle", "last"]
# => "firstmiddlelast"
# plus => { [-> (:a, &proc) { proc[a] }, :plus ] }; local_variable_set(:plus, plus);
# fn[:transform, [:list, :proc], [ eachdo, :args ] ]; transform[ [[1,2,3]] ] { it * 2 }
#
# fn[:concat, [:a, :b], `a + b` ]; concat['first', 'last']
# => [#<Proc>, "first", "last"]
# fn[:concat, [:args], `args.join` ]; concat['first', 'middle', 'last']
# => [#<Proc>, "first", "middle", "last"]
# => "firstmiddlelast"
# fn[:dotwice, [:a, :proc], `proc[a] + proc[a]` ]; dotwice['keith'] { "Hello #{it}" }
# => [#<Proc>, "keith", #<Proc>]
# => "Hello keithHello keith"

fn = ->(name, vars, o = nil, &block) {
  vars = Array(vars)
  raise ArgumentError, "The second element must be a symbol or an array of symbols:  fn[:func, [:a, :b], ...]" unless vars.all? { |v| v.is_a?(Symbol) }
  args = vars.map { |v| v = v.to_s; if v == "args" then "*args" elsif v == "proc" then "&proc" else v end }.join(',')

  case o
  in [prc, *rest] if prc.is_a?(Proc) # works with args BUT TEST PROC
    raise "The body of the fn includes a proc which is not an fn. The proc in here: #{o.inspect}" unless (prc[] rescue false) && (prc[] in [Proc, Symbol])
    local_variable_set(name, eval("->(#{args}) { #{[ prc[][1], *rest ].inspect(*vars)} }"))
  in String # works with args & proc
    local_variable_set(name, eval("->(#{args}) { [ ->{ [ ->(#{args}) { #{o} }, :anonymous] }, #{vars.join(',')}] }")) # Does this works with the two special args
  in nil
    # HERE test special args
    raise ArgumentError, "When defining a function without specifying the body, a block is expected:  fn[:func, [:a, :b]] { ... }" unless block_given?
    local_variable_set(name, ->(*vars) { block[*vars] })
  in Proc
    local_variable_set(name, ->(*vars) { o[*vars] })
  end
}

local_variable_set(:fn, fn)
