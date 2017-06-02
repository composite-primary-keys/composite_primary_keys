require File.expand_path('../abstract_unit', __FILE__)

class TestFindInBatches < ActiveSupport::TestCase
  fixtures :capitols

  def test_in_batches
    capitols = []
    Capitol.find_in_batches do |chunk|
      capitols += chunk.map(&:country)
    end

    assert_equal(capitols, ['Canada', 'France', 'Mexico', 'The Netherlands'])
  end

  def test_in_small_batches
    capitols = []
    Capitol.find_in_batches(batch_size: 2) do |chunk|
      capitols += chunk.map(&:country)
    end

    assert_equal(capitols, ['Canada', 'France', 'Mexico', 'The Netherlands'])
  end

  def test_in_one_unit_batch
    capitols = []
    Capitol.find_in_batches(batch_size: 1) do |chunk|
      capitols += chunk.map(&:country)
    end

    assert_equal(capitols, ['Canada', 'France', 'Mexico', 'The Netherlands'])
  end
end

