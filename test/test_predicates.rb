require File.expand_path('../abstract_unit', __FILE__)

class TestPredicates < ActiveSupport::TestCase
  fixtures :departments

  include CompositePrimaryKeys::Predicates

  def test_or
    dep = Department.arel_table

    predicates = Array.new

    3.times do |i|
      predicates << dep[:id].eq(i)
    end

    connection = ActiveRecord::Base.connection
    quoted = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    expected = "(#{quoted} = 0 OR #{quoted} = 1 OR #{quoted} = 2)"

    pred = cpk_or_predicate(predicates)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end

  def test_or_with_many_values
    dep = Arel::Table.new(:departments)

    predicates = Array.new

    number_of_predicates = 3000 # This should really be big
    number_of_predicates.times do |i|
      predicates << dep[:id].eq(i)
    end

    connection = ActiveRecord::Base.connection
    quoted = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    expected_ungrouped = ((0...number_of_predicates).map { |i| "#{quoted} = #{i}" }).join(' OR ')
    expected = "(#{expected_ungrouped})"

    pred = cpk_or_predicate(predicates)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end

  def test_and
    dep = Department.arel_table

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

  def test_in
    dep = Department.arel_table

    primary_keys = [[1, 1], [1, 2]]

    connection = ActiveRecord::Base.connection
    quoted_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    quoted_location_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('location_id')}"
    expected = "#{quoted_id_column} = 1 AND #{quoted_location_id_column} IN (1, 2)"

    pred = cpk_in_predicate(dep, [:id, :location_id], primary_keys)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end

  def test_in_with_low_cardinality_second_key_part
    dep = Department.arel_table

    primary_keys = [[1, 1], [2, 1]]

    connection = ActiveRecord::Base.connection
    quoted_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    quoted_location_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('location_id')}"
    expected = "#{quoted_location_id_column} = 1 AND #{quoted_id_column} IN (1, 2)"

    require 'byebug'
    byebug

    pred = cpk_in_predicate(dep, [:id, :location_id], primary_keys)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end

  def test_in_with_nil_primary_key_part
    dep = Department.arel_table

    primary_keys = [[nil, 1], [nil, 2]]

    connection = ActiveRecord::Base.connection
    quoted_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    quoted_location_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('location_id')}"
    expected = "#{quoted_id_column} IS NULL AND #{quoted_location_id_column} IN (1, 2)"

    pred = cpk_in_predicate(dep, [:id, :location_id], primary_keys)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end

  def test_in_with_nil_secondary_key_part
    dep = Department.arel_table

    primary_keys = [[1, 1], [1, nil]]

    connection = ActiveRecord::Base.connection
    quoted_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    quoted_location_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('location_id')}"
    expected = "#{quoted_id_column} = 1 AND (#{quoted_location_id_column} IN (1) OR #{quoted_location_id_column} IS NULL)"

    pred = cpk_in_predicate(dep, [:id, :location_id], primary_keys)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end

  def test_in_with_multiple_primary_key_parts
    dep = Department.arel_table

    primary_keys = [[1, 1], [1, 2], [2, 3], [2, 4]]

    connection = ActiveRecord::Base.connection
    quoted_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('id')}"
    quoted_location_id_column = "#{connection.quote_table_name('departments')}.#{connection.quote_column_name('location_id')}"
    expected = "(#{quoted_id_column} = 1 AND #{quoted_location_id_column} IN (1, 2) OR #{quoted_id_column} = 2 AND #{quoted_location_id_column} IN (3, 4))"

    pred = cpk_in_predicate(dep, [:id, :location_id], primary_keys)
    assert_equal(with_quoted_identifiers(expected), pred.to_sql)
  end
end
