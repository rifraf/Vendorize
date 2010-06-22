$LOAD_PATH.unshift File.dirname(__FILE__)

require 'test/unit'
require 'lib/rubies'
require 'lib/test_support'

# Pull in vendorize so we can get constants, but without
# doing the overrides. Otherwise we disrupt the test code...
ENV['NO_VENDORIZE'] = 'Testing'
require 'vendorize'
ENV['NO_VENDORIZE'] = nil


class TestForcedCache < Test::Unit::TestCase

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

  def test_can_cache_all_files_in_gem
    vendorize_testfile('gem_cache_all.rb') { |output|
      vendor_set = files_in_cache
      assert vendor_set.include?('./_vendor_/rake.rb')  # Normal
      # These don't come in without a full directory grab
      assert vendor_set.include?('./_vendor_/rake/clean.rb')
      assert vendor_set.include?('./_vendor_/rake/gempackagetask.rb')
    }
  end

  def test_vendorize_will_add_directories
    vendorize_testfile('simple_add.rb') { |output|  # does Vendorize.add_dir('cgi')
      vendor_set = files_in_cache
      assert vendor_set.include?('./_vendor_/cgi/session.rb')
      assert vendor_set.include?('./_vendor_/cgi/session/pstore.rb')
    }
  end

  def test_can_cache_additional_files
    return if RUBY_VERSION =~ /1\.9/  # Different test/unit in library

    # First stage just requires test/unilt
    ENV['TEST_STAGE'] = '1'
    vendorize_testfile('multi_add.rb') { |output|
      #ENV['keep_folder'] = '__test_can_cache_additional_files'
      #puts output
      first_vendor_set = files_in_cache
      assert((15 < first_vendor_set.length), "Should give at least 15 files (on my machine...)")

      # Second stage adds one requireable file
      ENV['TEST_STAGE'] = '2'
      vendorize_file('multi_add.rb') { |output|
        #puts output
        second_vendor_set = files_in_cache
        assert_equal(first_vendor_set.length + 1, second_vendor_set.length, "Should have added one file)")

        # Third stage adds one specified file
        ENV['TEST_STAGE'] = '3'
        vendorize_file('multi_add.rb') { |output|
          #puts output
          third_vendor_set = files_in_cache
          assert_equal(second_vendor_set.length + 1, third_vendor_set.length, "Should have added one file)")

          # Fourth stage adds files in directory
          ENV['TEST_STAGE'] = '4'
          vendorize_file('multi_add.rb') { |output|
            #puts output
            fourth_vendor_set = files_in_cache
            assert_equal(third_vendor_set.length + 3, fourth_vendor_set.length, "Should have added remaining files)")
          }
        }
      }
    }
  end

end
