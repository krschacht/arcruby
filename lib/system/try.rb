class Object
  def try(name)
    if respond_to?(name)
      send(name)
    else
      nil
    end
  end
end
