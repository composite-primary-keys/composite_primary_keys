$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../../activesupport/lib')

require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require 'active_support/binding_of_caller'
require 'active_support/breakpoint'
require 'connection'
require 'composite_primary_keys'
require 'composite_primary_keys/fixtures'

QUOTED_TYPE = ActiveRecord::Base.connection.quote_column_name('type') unless Object.const_defined?(:QUOTED_TYPE)

class Test::Unit::TestCase #:nodoc:
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
  self.use_instantiated_fixtures = false
  self.use_transactional_fixtures = (ENV['AR_NO_TX_FIXTURES'] != "yes")

  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures/", table_names, {}, &block)
  end
  
  def assert_date_from_db(expected, actual, message = nil)
    # SQL Server doesn't have a separate column type just for dates, 
    # so the time is in the string and incorrectly formatted
    if current_adapter?(:SQLServerAdapter)
      assert_equal expected.strftime("%Y/%m/%d 00:00:00"), actual.strftime("%Y/%m/%d 00:00:00")
    elsif current_adapter?(:SybaseAdapter)
      assert_equal expected.to_s, actual.to_date.to_s, message
    else
      assert_equal expected.to_s, actual.to_s, message
    end
  end

  def assert_queries(num = 1)
    ActiveRecord::Base.connection.class.class_eval do
      self.query_count = 0
      alias_method :execute, :execute_with_query_counting
    end
    yield
  ensure
    ActiveRecord::Base.connection.class.class_eval do
      alias_method :execute, :execute_without_query_counting
    end
    assert_equal num, ActiveRecord::Base.connection.query_count, "#{ActiveRecord::Base.connection.query_count} instead of #{num} queries were executed."
  end

  def assert_no_queries(&block)
    assert_queries(0, &block)
  end
  
  cattr_accessor :classes
protected
  
  def testing_with(&block)
    classes.keys.each do |@key_test|
      @klass_info = classes[@key_test]
      @klass, @primary_keys = @klass_info[:class], @klass_info[:primary_keys]
      @first = @klass.find_first
      yield
    end
  end
  
  def first_id
    (1..@primary_keys.length).map {|num| 1}
  end
  
  def first_id_str
    first_id.join(CompositePrimaryKeys::ID_SEP)
  end
  
  def composite?
    @key_test != :single
  end  
end

def current_adapter?(type)
  ActiveRecord::ConnectionAdapters.const_defined?(type) &&
    ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters.const_get(type))
end

ActiveRecord::Base.connection.class.class_eval do
  cattr_accessor :query_count
  alias_method :execute_without_query_counting, :execute
  def execute_with_query_counting(sql, name = nil)
    self.query_count += 1
    execute_without_query_counting(sql, name)
  end
end

#ActiveRecord::Base.logger = Logger.new(STDOUT)
#ActiveRecord::Base.colorize_logging = false
