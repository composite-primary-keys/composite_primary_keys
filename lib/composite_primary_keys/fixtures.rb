class Fixture
  def [](key)
    if key.is_a? Array
      key.map { |a_key| self[a_key.to_s] }
    else
      @fixture[key]
    end
  end
end
