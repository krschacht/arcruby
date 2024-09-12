$all_df_defined = {}

def df_set(variable, value)
  $all_df_defined[variable.to_sym] = value
end

def df_get(variable)
  $all_df_defined[variable.to_sym]
end

def df_defined?(variable)
  $all_df_defined.key?(variable.to_sym)
end
