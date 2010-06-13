$LOAD_PATH.unshift File.dirname(__FILE__)

require 'test/unit'
require 'lib/rubies'
require 'lib/test_support'

# Pull in vendorize so we can get constants, but without
# doing the overrides. Otherwise we disrupt the test code...
ENV['NO_VENDORIZE'] = 'Testing'
require 'vendorize'
ENV['NO_VENDORIZE'] = nil


class TestLoads < Test::Unit::TestCase

  include VendorizeTestSupport

  def setup
    ENV['rubyopt'] = nil
    ENV['_Vendor_'] = nil
    ENV['keep_folder'] = nil
    @here = Dir.getwd
  end

  def teardown
    Dir.chdir(@here)
  end

  def test_should_cache_one_file_for_a_single_load
    vendorize_testfile('simple_load.rb') { |output|
      assert File.exists?(File.join(Vendorize.root_folder, 'no_loads.rb'))
    }
  end

end
