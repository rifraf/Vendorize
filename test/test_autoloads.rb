$LOAD_PATH.unshift File.dirname(__FILE__)

require 'test/unit'
require 'lib/rubies'
require 'lib/test_support'

# Pull in vendorize so we can get constants, but without
# doing the overrides. Otherwise we disrupt the test code...
ENV['NO_VENDORIZE'] = 'Testing'
require 'vendorize'
ENV['NO_VENDORIZE'] = nil


class TestAutoloads < Test::Unit::TestCase

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

  def test_should_cache_one_file_for_a_kernel_autoload
    vendorize_testfile('kernel_autoload.rb') { |output|
      #puts output
      # TODO assert File.exists?(File.join(Vendorize.root_folder, 'no_loads.rb'))
    }
  end

  def test_should_cache_one_file_for_a_module_autoload
    vendorize_testfile('module_autoload.rb') { |output|
      assert File.exists?(File.join(Vendorize.root_folder, 'no_loads.rb'))
    }
  end

end
