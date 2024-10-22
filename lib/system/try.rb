class Object
  def try(name, *args)
    if respond_to?(name)
      send(name, *args)
    else
      nil
    end
  end
end
