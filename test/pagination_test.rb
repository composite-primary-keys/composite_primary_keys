require 'abstract_unit'
require 'fixtures/reference_type'
require 'fixtures/reference_code'
require 'action_controller/pagination'

class PaginationTest < Test::Unit::TestCase
  include ActionController::Pagination
  DEFAULT_PAGE_SIZE = 2
  
  @@classes = {
    :single => {
      :class => ReferenceType,
      :primary_keys => [:reference_type_id],
    },
    :dual   => { 
      :class => ReferenceCode,
      :primary_keys => [:reference_type_id, :reference_code],
    }
  }
  
  def setup
    @params = {}
  end

  def test_paginate_all
    testing_with do
      @object_pages, @objects = paginate :reference_codes, :per_page => DEFAULT_PAGE_SIZE
      assert_equal 2, @objects.length, "Each page should have #{DEFAULT_PAGE_SIZE} items"
    end
  end
end