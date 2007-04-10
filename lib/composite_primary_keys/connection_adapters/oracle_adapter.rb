module ActiveRecord
  module ConnectionAdapters
    class OracleAdapter < AbstractAdapter
      
      # This mightn't be in Core, but count(distinct x,y) doesn't work for me
      def supports_count_distinct? #:nodoc:
        false
      end
    end
  end
end