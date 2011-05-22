module ActiveRecord
  class Fixture
    def find
      if model_class
        # CPK
        # model_class.find(fixture[model_class.primary_key])
        ids = self.ids(model_class.primary_key)
        model_class.find(ids)
      else
        raise FixtureClassNotFound, "No class attached to find."
      end
    end

    def ids(key)
      if key.is_a? Array
        key.map {|a_key| fixture[a_key.to_s] }
      else
        fixture[key]
      end
    end
  end
end
