require File.expand_path('../abstract_unit', __FILE__)

def has_callbacks(obj, action, options = {})
  obj.expects(:"before_#{action}_method")
  obj.expects(:"after_#{action}_method")
  obj.expects(:"around_#{action}_method")
end

class TestCallbacks < ActiveSupport::TestCase
  fixtures :model_with_callbacks

  def test_save_callbacks
    obj = ModelWithCallback.first
    has_callbacks(obj, :save)
    obj.save
  end

  def test_create_callbacks
    obj = ModelWithCallback.new
    has_callbacks(obj, :create)
    obj.save!
  end

  def test_update_callbacks
    obj = ModelWithCallback.first
    has_callbacks(obj, :update)
    obj.reference_code = 4
    obj.save!
  end

  def test_destroy_callbacks
    obj = ModelWithCallback.first
    has_callbacks(obj, :destroy)
    obj.destroy
  end
end
