require File.expand_path('../abstract_unit', __FILE__)

class TestCalculations < ActiveSupport::TestCase
  fixtures :tariffs

  def test_update_counter
    tariff = tariffs(:flat)
    assert_equal(50, tariff.amount)
    Tariff.update_counters(tariff.id, :amount => 1)
    tariff.reload
    assert_equal(51, tariff.amount)
  end

  def test_update_counter_for_many
    tariff1 = tariffs(:flat)
    tariff2 = tariffs(:free)
    assert_equal(50, tariff1.amount)
    assert_equal(0, tariff2.amount)
    Tariff.update_counters([tariff1.id, tariff2.id], :amount => 1)
    tariff1.reload
    tariff2.reload
    assert_equal(51, tariff1.amount)
    assert_equal(1, tariff2.amount)
  end

  def test_increment_counter
    tariff = tariffs(:flat)
    assert_equal(50, tariff.amount)
    Tariff.increment_counter(:amount, tariff.id)

    tariff.reload
    assert_equal(51, tariff.amount)
  end

  def test_decrement_counter
    tariff = tariffs(:flat)
    assert_equal(50, tariff.amount)
    Tariff.decrement_counter(:amount, tariff.id)

    tariff.reload
    assert_equal(49, tariff.amount)
  end
end
