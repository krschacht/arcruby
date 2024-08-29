# This overrides the .inspect method on array to accept optional list of symbols.
# These symbols are instructions to replace any matching symbols with their name
# e.g.
# > [ "first", [ :a, "cat" ], [ "dog", :b ] ].inspect
# => "[\"first\", [:a, \"cat\"], [\"dog\", :b]]"
#
# > [ "first", [ :a, "cat" ], [ "dog", :b ] ].inspect(:a)
# => "[\"first\", [a, \"cat\"], [\"dog\", :b]]"

class Array
  def inspect(*args)
    unless args.all? { |arg| arg.is_a?(Symbol) }
      raise ArgumentError, "All arguments to inspect must be symbols"
    end

    map do |element|
      if element.is_a?(Array)
        element.inspect(*args)
      elsif element.is_a?(Symbol) && args.include?(element)
        element.to_s
      else
        element.inspect
      end
    end.join(", ").prepend("[").concat("]")
  end
end