$LOAD_PATH.unshift File.dirname(__FILE__)

require 'test/unit'
require 'lib/rubies'
require 'lib/test_support'

# Pull in vendorize so we can get constants, but without
# doing the overrides. Otherwise we disrupt the test code...
ENV['NO_VENDORIZE'] = 'Testing'
require 'vendorize'
ENV['NO_VENDORIZE'] = nil


class TestBundlerCache < Test::Unit::TestCase

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

  def test_work_with_bundler
    if [:mingw187, :mingw191].include? Ruby.version # Not all my Rubies have bundler...
      vendorize_testfile('bundled.rb') { |output|
        #puts output
        vendor_set = files_in_cache
        #puts vendor_set
        assert vendor_set.include?('./_vendor_/nokogiri/xml/attr.rb')
      }
    end
  end

end
