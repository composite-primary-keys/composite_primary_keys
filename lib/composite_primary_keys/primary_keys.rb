module CompositePrimaryKeys
  ID_SEP = ','
  
  class PrimaryKeys < Array

    def to_s
      join(ID_SEP)
    end
  end
end