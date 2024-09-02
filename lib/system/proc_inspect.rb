class Proc
  def inspect
    "#<#{":#{self[].last}" rescue "Proc"}>"
  end
end