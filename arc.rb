~[:df, :prn, :s, 'print s']
~[:df, :car, :lst, 'lst.first' ]
~[:df, :cdr, :lst, 'lst.drop(1)' ]
~[:df, :string, :args, 'args.join' ]
~[:df, :int, :s, 's.to_i' ]
~[:df, :map, [:func, :lst], 'lst.map { |item| func[item] }' ] # ~[:map, fn[[:x], 'x+1'], [1, 2, 3]]
~[:df, :each, [:var, :list, :block], "[map, fn[var, block], list]" ] # TODO: change this to [:fn, ...] # ~[:each, :name, ['keith', 'pari'], [:prn, [:string, 'hello ', :name]]]
~[:df, [:max, :_max], [:lst], 'lst.max' ]
~[:df, [:min, :_min], [:lst], 'lst.min' ]
~[:df, :pair, :args, 'args.flatten.each_slice(2).to_a' ]
~[:df, :dftem, [:args], [:const_set, [:car, :args], [:struct, [:cdr, :args]]]]
~[:df, :save_table, [:post, ], [:const_set, [:car, :args], [:struct, [:cdr, :args]]]]
~[:df, :ensure_dir, :path, [if_false, [dir_exists, :path], [sys, [string, 'mkdir -p ', :path]]]]
~[:df, :writefile, [:val, :file], 'tmpfile = "#{file}.tmp"; dir = File.dirname(tmpfile); ~ensure_dir[dir]; File.open(tmpfile, "w") { |o| o.write(val) }; File.rename(tmpfile, file); val']
~[:df, :tablist, :obj, 'obj.to_h']
~[:df, :save_table, [:h, :file], [writefile, [tablist, :h], :file]]
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