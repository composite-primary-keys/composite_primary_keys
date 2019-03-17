module ActiveRecord
  class Fixture
    def find
      raise FixtureClassNotFound, "No class attached to find." unless model_class
      model_class.unscoped do
        # CPK
        #model_class.find(fixture[model_class.primary_key])
        ids = self.ids(model_class.primary_key)
        model_class.find(ids)
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
