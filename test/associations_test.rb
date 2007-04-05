require 'abstract_unit'
require 'fixtures/product'
require 'fixtures/tariff'
require 'fixtures/product_tariff'
require 'fixtures/suburb'
require 'fixtures/street'

class AssociationTest < Test::Unit::TestCase

  def setup
    create_fixtures :products, :tariffs, :product_tariffs, :suburbs, :streets
    @first_product = Product.find(1)
    @flat = Tariff.find(1, Date.today.to_s(:db))
    @free = Tariff.find(2, Date.today.to_s(:db))
    @first_flat = ProductTariff.find(1, 1, Date.today.to_s(:db))
  end
  
  def test_setup
    assert_not_nil @first_product
    assert_not_nil @flat
    assert_not_nil @free
    assert_not_nil @first_flat
  end
  
  def test_quoted_table_columns
    assert_equal "product_tariffs.product_id,product_tariffs.tariff_id,product_tariffs.tariff_start_date", 
        ProductTariff.send(:quoted_table_columns, ProductTariff.primary_key)
  end
  
  def test_count
    assert_equal 2, Product.count(:include => :product_tariffs)
    assert_equal 3, Tariff.count(:include => :product_tariffs)
  end
  
  def test_products
    assert_not_nil @first_product.product_tariffs
    assert_equal 2, @first_product.product_tariffs.length
    assert_not_nil @first_product.tariffs
    assert_equal 2, @first_product.tariffs.length
    assert_not_nil @first_product.product_tariff
  end
  
  def test_product_tariffs
    assert_not_nil @first_flat.product
    assert_not_nil @first_flat.tariff
    assert_equal Product, @first_flat.product.class
    assert_equal Tariff, @first_flat.tariff.class
  end
  
  def test_tariffs
    assert_not_nil @flat.product_tariffs
    assert_equal 1, @flat.product_tariffs.length
    assert_not_nil @flat.products
    assert_equal 1, @flat.products.length
    assert_not_nil @flat.product_tariff
  end
  
  # Its not generating the instances of associated classes from the rows
  def test_find_includes_products
    assert @products = Product.find(:all, :include => :product_tariffs)
    assert_equal 2, @products.length
    assert_not_nil @products.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @products.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length}, "Incorrect number of product_tariffs returned"
  end
  
  def test_find_includes_tariffs
    assert @tariffs = Tariff.find(:all, :include => :product_tariffs)
    assert_equal 3, @tariffs.length
    assert_not_nil @tariffs.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @tariffs.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length}, "Incorrect number of product_tariffs returned"
  end
  
  def XXX_test_find_includes_extended
    # TODO - what's the correct syntax?
    assert @products = Product.find(:all, :include => {:product_tariffs => :tariffs})
    assert_equal 3, @products.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length}, "Incorrect number of product_tariffs returned"
    
    assert @tariffs = Tariff.find(:all, :include => {:product_tariffs => :products})
    assert_equal 3, @tariffs.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length}, "Incorrect number of product_tariffs returned"
    
  end
  
end
