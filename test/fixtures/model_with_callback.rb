class ModelWithCallback < ActiveRecord::Base
  after_save  :after_save_method
  before_save :before_save_method
  around_save :around_save_method

  after_create  :after_create_method
  before_create :before_create_method
  around_create :around_create_method

  after_update  :after_update_method
  before_update :before_update_method
  around_update :around_update_method

  after_destroy  :after_destroy_method
  before_destroy :before_destroy_method
  around_destroy :around_destroy_method

  private

  # Save callbacks
  def after_save_method  ; end
  def before_save_method ; end
  def around_save_method ; yield ; end

  # Create callbacks
  def after_create_method  ; end
  def before_create_method ; end
  def around_create_method ; yield ;end

  # Update callbacks
  def after_update_method  ; end
  def before_update_method ; end
  def around_update_method ; yield ; end

  # Destroy callbacks
  def after_destroy_method  ; end
  def before_destroy_method ; end
  def around_destroy_method ; yield ; end
end
