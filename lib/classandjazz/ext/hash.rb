class Hash

  def method_missing(name, *args, &block)
    if has_key?(name.to_s)
      fetch(name.to_s)
    elsif has_key?(name.to_sym)
      fetch(name.to_sym)
    else
      super
    end
  end

end
