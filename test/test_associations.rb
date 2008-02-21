require 'abstract_unit'
require 'fixtures/product'
require 'fixtures/tariff'
require 'fixtures/product_tariff'
require 'fixtures/suburb'
require 'fixtures/street'
require 'fixtures/restaurant'

class TestAssociations < Test::Unit::TestCase
  fixtures :products, :tariffs, :product_tariffs, :suburbs, :streets, :restaurants, :restaurants_suburbs
  
  def test_quoted_table_columns
    assert_equal "product_tariffs.product_id,product_tariffs.tariff_id,product_tariffs.tariff_start_date", 
        ProductTariff.send(:quoted_table_columns, ProductTariff.primary_key)
  end
  
  def test_count
    assert_equal 2, Product.count(:include => :product_tariffs)
    assert_equal 3, Tariff.count(:include => :product_tariffs)
  end
  
  def test_products
    assert_not_nil products(:first_product).product_tariffs
    assert_equal 2, products(:first_product).product_tariffs.length
    assert_not_nil products(:first_product).tariffs
    assert_equal 2, products(:first_product).tariffs.length
    assert_not_nil products(:first_product).product_tariff
  end
  
  def test_product_tariffs
    assert_not_nil product_tariffs(:first_flat).product
    assert_not_nil product_tariffs(:first_flat).tariff
    assert_equal Product, product_tariffs(:first_flat).product.class
    assert_equal Tariff, product_tariffs(:first_flat).tariff.class
  end
  
  def test_tariffs
    assert_not_nil tariffs(:flat).product_tariffs
    assert_equal 1, tariffs(:flat).product_tariffs.length
    assert_not_nil tariffs(:flat).products
    assert_equal 1, tariffs(:flat).products.length
    assert_not_nil tariffs(:flat).product_tariff
  end
  
  # Its not generating the instances of associated classes from the rows
  def test_find_includes_products
    assert @products = Product.find(:all, :include => :product_tariffs)
    assert_equal 2, @products.length
    assert_not_nil @products.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @products.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length}, 
      "Incorrect number of product_tariffs returned"
  end
  
  def test_find_includes_tariffs
    assert @tariffs = Tariff.find(:all, :include => :product_tariffs)
    assert_equal 3, @tariffs.length
    assert_not_nil @tariffs.first.instance_variable_get('@product_tariffs'), '@product_tariffs not set; should be array'
    assert_equal 3, @tariffs.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length}, 
      "Incorrect number of product_tariffs returnedturned"
  end
  
  def test_find_includes_product
    assert @product_tariffs = ProductTariff.find(:all, :include => :product)
    assert_equal 3, @product_tariffs.length
    assert_not_nil @product_tariffs.first.instance_variable_get('@product'), '@product not set'
  end
  
  def test_find_includes_comp_belongs_to_tariff
    assert @product_tariffs = ProductTariff.find(:all, :include => :tariff)
    assert_equal 3, @product_tariffs.length
    assert_not_nil @product_tariffs.first.instance_variable_get('@tariff'), '@tariff not set'
  end
  
  def test_find_includes_extended
    assert @products = Product.find(:all, :include => {:product_tariffs => :tariff})
    assert_equal 3, @products.inject(0) {|sum, product| sum + product.instance_variable_get('@product_tariffs').length},
      "Incorrect number of product_tariffs returned"
    
    assert @tariffs = Tariff.find(:all, :include => {:product_tariffs => :product})
    assert_equal 3, @tariffs.inject(0) {|sum, tariff| sum + tariff.instance_variable_get('@product_tariffs').length}, 
      "Incorrect number of product_tariffs returned"
  end
  
  def test_join_where_clause
    @product = Product.find(:first, :include => :product_tariffs)
    where_clause = @product.product_tariffs.composite_where_clause(
      ['foo','bar'], [1,2]
    )
    assert_equal('(foo=1 AND bar=2)', where_clause)
  end
  
  def test_has_many_through
    @products = Product.find(:all, :include => :tariffs)
    assert_equal 3, @products.inject(0) {|sum, product| sum + product.instance_variable_get('@tariffs').length},
      "Incorrect number of tariffs returned"
  end

  def test_associations_with_conditions
    @suburb = Suburb.find([2, 1])
    assert_equal 2, @suburb.streets.size

    @suburb = Suburb.find([2, 1])
    assert_equal 1, @suburb.first_streets.size

    @suburb = Suburb.find([2, 1], :include => :streets)
    assert_equal 2, @suburb.streets.size

    @suburb = Suburb.find([2, 1], :include => :first_streets)
    assert_equal 1, @suburb.first_streets.size
  end
  
  def test_has_and_belongs_to_many
    @restaurant = Restaurant.find([1,1])
    assert_equal 2, @restaurant.suburbs.size
    
    @restaurant = Restaurant.find([1,1], :include => :suburbs)
    assert_equal 2, @restaurant.suburbs.size  
  end
end
