~[:df, :prn, :s, 'print s']
~[:df, :car, :lst, 'lst.first' ]
~[:df, :cdr, :lst, 'lst.drop(1)' ]
~[:df, :last, :lst, 'lst.last' ]
~[:df, :string, :args, 'args.join' ]
~[:df, :int, :s, 's.to_i' ]
~[:df, :map, [:df_or_fn, :lst], 'lst.map { |item| df_or_fn.is_a?(Fn) ? df_or_fn[item] : ~df_or_fn[item] }' ] # ~[:map, [fn, [:x], 'x+1'], [1, 2, 3]]   and also:   ~[:map, int, ['1', '2', '3']]  TODO: Should I make it work with a symbol?  ~[:map, :int, ['1', '2', '3']]
~[:df, :each, [:var, :list, :block], [map, [fn, :var, :block], :list] ] # TODO: change this to [:fn, ...] # ~[:each, :name, ['keith', 'pari'], [:prn, [:string, 'hello ', :name]]]
~[:df, :max, [:args], 'args.map { |i| i.is_a?(Symbol) ? TOPLEVEL_BINDING.eval("self").instance_variable_get(i) : i }.max' ]
~[:df, :min, [:args], 'args.map { |i| i.is_a?(Symbol) ? TOPLEVEL_BINDING.eval("self").instance_variable_get(i) : i }.min' ]
~[:df, :pair, :args, 'args.flatten.each_slice(2).to_a' ]
~[:df, :dftem, [:name, :args], [:const_set, :name, [:struct, :args]]]
~[:df, :ensure_dir, :path, [if_false, [dir_exists, :path], [sys, [string, 'mkdir -p ', :path]]]]
~[:df, :writefile, [:val, :file], 'tmpfile = "#{file}.tmp"; dir = File.dirname(tmpfile); ~ensure_dir[dir]; File.open(tmpfile, "w") { |o| o.write(val) }; File.rename(tmpfile, file); val']
~[:df, :tablist, :obj, 'obj.to_h']
~[:df, :save_table, [:h, :file], [writefile, [tablist, :h], :file]]
~[:df, :read, [:file], 'File.read(file)']
~[:df, :templatize, [:tem, :lst], 'Object.const_get(tem).new(*lst.values)']
~[:df, :temload, [:tem, :file], [templatize, :tem, [evl, [read, :file]]]]
# ~[:each, :i, [1,2,3],

# fn[]
# (mac each (var expr . body) `(map (fn (,var) ,@body) ,expr))


# This map method works with two styles:
# ~[:map, fn[[:x], 'x+1'], [1, 2, 3]]
# ~[:df, :plusone, [:x], 'x+1']; ~[:map, plusone, [1, 2, 3]]
# Can I make it also accept :plusone? I'd need to modify the original method definition to recognize that func is special. Or, I could make it so anytime a method takes a symbol and that symbol matches a fn to substitute.
# ~[:map, :plusone, [1, 2, 3]]

# Now I need to figure out why I can't name a function map

# (each name '(Alice Bob Charlie) (prn (string "Hello " name)))

# [:fn, :x, 'x + 1']



# TODO: figure out why my example of eech works below but the example above doesn't work. Are 2 names not working? Or is a _name not allowed?