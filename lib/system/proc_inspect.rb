if defined?(IRB) || defined?(Pry)
  class Proc
    def inspect
      "#<#{":#{(arr = self[]) && arr.is_a?(Array) && arr.length == 2 && (arr in [Proc, Symbol]) ? arr.last : "Proc"}" rescue "Proc"}>"
    end
  end
end