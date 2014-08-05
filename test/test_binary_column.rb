require File.expand_path('../abstract_unit', __FILE__)

class TestBinaryColumn < ActiveSupport::TestCase
  def test_binary_data_save
    s = Spreadsheet.new
    data = Marshal.dump({})
    s.data = data
    assert_equal(data, s.data)
    assert_equal({}, Marshal.load(s.data))
  end
end
