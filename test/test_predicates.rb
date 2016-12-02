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
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end

  def test_large_or
    dep = Arel::Table.new(:departments)

    predicates = Array.new

    1500.times do |i|
      predicates << dep[:id].eq(i)
    end

    connection = ActiveRecord::Base.connection
    quoted = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    sql = cpk_or_predicate(predicates).to_s

    assert sql.start_with?(with_quoted_identifiers("((#{quoted} = 0) OR (#{quoted} = 1)"))
    assert sql.end_with?(with_quoted_identifiers("(#{quoted} = 1498) OR (#{quoted} = 1499))"))
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
