$all_fn_defined = {}

def fn_set(variable, value)
  $all_fn_defined[variable.to_sym] = value
end

def fn_get(variable)
  $all_fn_defined[variable.to_sym]
end

# def fn?(variable)
#   $all_fn_defined.key?(variable.to_sym)
# end
