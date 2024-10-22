$all_fn_defined = {}

def fn_set(variable, value)
  raise "value is not an Fn or a MacFn" unless [Fn, MacFn].include?(value.class)
  $all_fn_defined[variable.to_sym] = value
end

def fn_get(variable)
  $all_fn_defined[variable.to_sym]
end

# def fn?(variable)
#   $all_fn_defined.key?(variable.to_sym)
# end
