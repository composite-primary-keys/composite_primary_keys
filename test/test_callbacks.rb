require File.expand_path('../abstract_unit', __FILE__)

class TestUpdate < ActiveSupport::TestCase
  fixtures :suburbs

  def setup
    @@callbacks = OpenStruct.new
  end

   Suburb.class_eval do
    before_create do
      @@callbacks.before_create = true
    end
    
    after_create do
      @@callbacks.after_create = true
    end
    
    around_create do |suburb, block|
      @@callbacks.around_create = true
      block.call
    end

    before_save do
      @@callbacks.before_save = true
    end

    after_save do
      @@callbacks.after_save = true
    end

    around_save do |suburb, block|
      @@callbacks.around_save = true
      block.call
    end

    before_update do
      @@callbacks.before_update = true
    end

    after_update do
      @@callbacks.after_update = true
    end

    around_update do |suburb, block|
      @@callbacks.around_update = true
      block.call
    end
  end

  def test_create
    suburb = Suburb.new(:city_id => 3, :suburb_id => 3, :name => 'created')
    suburb.save!

    assert(@@callbacks.before_save)
    assert(@@callbacks.after_save)
    assert(@@callbacks.around_save)

    assert(@@callbacks.before_create)
    assert(@@callbacks.after_create)
    assert(@@callbacks.around_create)
  end

  def test_update
    suburb = suburbs(:first)
    suburb.name = 'Updated'
    suburb.save

    assert(@@callbacks.before_update)
    assert(@@callbacks.after_update)
    assert(@@callbacks.around_update)

    assert(@@callbacks.before_save)
    assert(@@callbacks.after_save)
    assert(@@callbacks.around_save)
  end
end