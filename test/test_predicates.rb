require File.expand_path('../abstract_unit', __FILE__)

class TestEqual < ActiveSupport::TestCase
  fixtures :departments

  include CompositePrimaryKeys::Predicates

  def test_or
    dep = Arel::Table.new(:departments)

    predicates = Array.new

    3.times do |i|
      predicates << dep[:id].eq(i)
    end

    connection = ActiveRecord::Base.connection
    quoted = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    expected = "((#{quoted} = 0) OR (#{quoted} = 1) OR (#{quoted} = 2))"

    pred = cpk_or_predicate(predicates)
    assert_equal(with_quoted_identifiers(expected), pred.to_s)
  end

  def test_and
    dep = Arel::Table.new(:departments)

    predicates = Array.new

    3.times do |i|
      predicates << dep[:id].eq(i)
    end

    connection = ActiveRecord::Base.connection
    quoted = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    expected = "#{quoted} = 0 AND #{quoted} = 1 AND #{quoted} = 2"

    pred = cpk_and_predicate(predicates)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end
end