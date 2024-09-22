require_relative 'system/df'
require_relative 'system/fn'
require_relative 'system/fn_n'
require_relative 'system/df_set'
require_relative 'system/local_variable_set'
#require_relative 'system/backticks'
require_relative 'system/array_proc_execution'
require_relative 'system/array_native_array_method'
require_relative 'system/array_freeze_method'
require_relative 'system/fn_factory'

#require_relative 'system/suffix_array_fn'

~[:df, :sys, :cmd, 'system(cmd)' ]
~[:df, :evl, :s, 'eval(s)' ]
~[:df, :upcase, :s, 's.to_s.upcase' ]
~[:df, :sym, :s, 's.to_sym' ]
~[:df, :ivar_set, [:key, :val], 'TOPLEVEL_BINDING.eval("self").instance_variable_set(key.to_s, val)' ]
~[:df, :const_set, [:key, :val], 'Object.const_set(~upcase[key], val)' ]
~[:df, :struct, :args, 'args = args.flatten; Struct.new(*args.each_slice(2).map(&:first)) do; define_method(:initialize) do |*fields|; super(*args.each_slice(2).map { |_, default| default }.zip(fields).map { |default, arg| arg.nil? ? default : arg }); end; end' ]
~[:df, :set, :args, 'args.each_slice(2) {|k,v| TOPLEVEL_BINDING.eval("self").instance_variable_set(k,v)}' ]
~[:df, :dir_exists, :path, 'Dir.exist?(path)' ]
~[:df, :if_true, [:val, :block], 'val && ~block' ]
~[:df, :if_false, [:val, :block], '!val && ~block' ] # this does not except macros
~[:df, :unless_true, [:val, :block], '!val && ~block' ]
~[:df, :unless_false, [:val, :block], 'val && ~block' ]


# DEBUG = false

# if DEBUG
#   greet1 = ->(name) { "hello1 #{name}" }
#   puts greet1["keith"]
# end

# if DEBUG
#   fn[:greet2, :name] { "hello2 #{_1}" }
#   puts greet2["keith"]

#   fn[:greet3, [:first, :last]] { "hello3 #{_1} #{_2}" }
#   puts greet3["keith", "smith"]

#   fn[:greet4, [:first, :last], '"hello4 #{first} #{last}"' ]
#   puts greet4["keith", "smith"]

#   fn[:greet5, [:first, :last], ->{ "hello5 #{_1} #{_2}" } ]
#   puts greet5["keith", "smith"]

#   sys["ls"]

#   puts ""
# end

# if DEBUG
#   _[fn, :sys2, :cmd, 'system(cmd)' ]
#   sys2["ls"]
#   puts ""
# end



# #ivar_set = ->(key, val){ instance_variable_set(key.to_s, val) }
# _[fn, :ivar_set, [:key, :val], 'instance_variable_set(key.to_s, val == "nil" ? nil : val)' ]
# #set = ->(*pairs){ pairs.each_slice(2) {|k, v| ivar_set["@#{k}".gsub('@@', '@'), v] }}
# _[fn, :set, :args, 'args.each_slice(2) {|k,v| ivar_set["@#{k}".gsub("@@", "@"), v] }' ]

# if DEBUG
#   puts ""

#   _[fn, :greet6, [:first, :last], '"hello6 #{first} #{last}"' ]
#   puts greet6["keith", "smith"]


#   #set[*%w[ @postdir arc/posts/  @maxid 0  @posts nil ]]
#   set["@postdir", "arc/posts/", "@maxid", 0,  "@posts", nil ]

#   puts @postdir
#   puts @maxid
#   puts @posts
#   puts ""

#   _[set, "@postdir", "NEW/posts/", maxid: 99, posts: nil]

#   puts @postdir
#   puts @maxid
#   puts @posts
#   puts ""

#   ~[set, "@postdir", "LAST/posts/", "@maxid", 50,  "@posts", nil]

#   puts @postdir
#   puts @maxid
#   puts @posts
#   puts ""

#   ~[set, "@postdir", "FINAL/posts/", "@maxid", 25,  "@posts", nil]

#   puts @postdir
#   puts @maxid
#   puts @posts
#   puts ""

#   %w[ :set @postdir VERY_FINAL/posts/  @maxid 10  @posts nil ]._

#   puts @postdir
#   puts @maxid
#   puts @posts
#   puts ""

#   [ "@postdir", "SUFFIX/posts/", { maxid: 5 }, "@posts", nil ].set

#   puts @postdir
#   puts @maxid
#   puts @posts
#   puts ""
# end