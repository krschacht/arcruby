~[:df, :prn, :s, 'print s']
~[:df, :car, :lst, 'lst.first' ]
~[:df, :cdr, :lst, 'lst.drop(1)' ]
~[:df, :cadr, :lst, [car, [cdr, :lst]] ]
~[:df, :last, :lst, 'lst.last' ]
~[:df, :string, :args, 'args.join' ]
~[:df, :int, :s, 's.to_i' ]
~[:mac, :map, [:df_or_fn, :lst], 'lst = ~lst if lst.class == ArrayProc; lst.map { |item| ~[df_or_fn, item] }' ] # ~[map, [fn, [:x], 'x+1'], [1, 2, 3]]   and also:   ~[:map, int, ['1', '2', '3']]  and also:   ~[map, int, [:dir, @postdir]]   TODO: Should I make it work with a symbol?  ~[:map, :int, ['1', '2', '3']]
~[:mac, :each, [:var, :list, :block], [map, [fn, :var, :block], :list] ] # TODO: change this to [:fn, ...]    # ~[:each, :name, ['keith', 'pari'], [:prn, [:string, 'hello ', :name]]]
~[:df, :max, [:args], 'args.map { |i| i.is_a?(Symbol) ? TOPLEVEL_BINDING.eval("self").instance_variable_get(i) : i }.max' ]
~[:df, :min, [:args], 'args.map { |i| i.is_a?(Symbol) ? TOPLEVEL_BINDING.eval("self").instance_variable_get(i) : i }.min' ]
~[:df, :pair, :args, 'args.flatten.each_slice(2).to_a' ]
~[:df, :dftem, [:name, :args], [:const_set, :name, [:struct, :args]]]
~[:df, :ensure_dir, :path, [if_true, :path, [if_false, [dir_exists, :path], [sys, [string, 'mkdir -p ', :path]]], [:err, "No path was provided to ensure_dir"]]]
~[:df, :writefile, [:val, :file], 'tmpfile = "#{file}.tmp"; dir = File.dirname(tmpfile); ~ensure_dir[dir]; File.open(tmpfile, "w") { |o| o.write(val) }; File.rename(tmpfile, file); val']
~[:df, :tablist, :obj, 'obj.to_h']
~[:df, :save_table, [:h, :file], [writefile, [tablist, :h], :file]]
~[:df, :read, [:file], 'File.read(file)']
~[:df, :templatize, [:tem, :lst], 'Object.const_get(tem).new(*lst.values)']
~[:df, :temload, [:tem, :file], [templatize, :tem, [evl, [read, :file]]]]
~[:df, :atom, :s, '!s.is_a?(Array)']

# (mac with (parms . body)
#   `((fn ,(map1 car (pair parms))
#      ,@body)
#     ,@(map1 cadr (pair parms))))

~[:mac, :with, [:parms, :args],       # ~[with, [:x, 1, :y, 2], [prn, :x]]  -- does this need to work with multiple args? I don't think so: ~[with, [:x, 1, :y, 2], [prn, :x], [prn, :y]]
  [[fn, [map, car, [pair, :parms]],
    :_args],
    [_map, cadr, [pair, :parms]]]]

# (mac let (var val . body)
#   `(with (,var ,val) ,@body))

~[:mac, :let, [:var, :val, :args],  # ~[let, :x, 1, [prn, :x]]
  [with, [:var, :val], :_args]]
