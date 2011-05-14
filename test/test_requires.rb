$LOAD_PATH.unshift File.dirname(__FILE__)

require 'test/unit'
require 'lib/rubies'
require 'lib/test_support'

# Pull in vendorize so we can get constants, but without
# doing the overrides. Otherwise we disrupt the test code...
ENV['NO_VENDORIZE'] = 'Testing'
require 'vendorize'
ENV['NO_VENDORIZE'] = nil


class TestRequires < Test::Unit::TestCase

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

  def test_should_create_no_folder_for_a_file_with_no_requires
    vendorize_testfile('no_loads.rb') { |output|
      assert !File.exists?(Vendorize.root_folder)
    }
  end

  def test_should_cache_one_file_for_a_single_require
    vendorize_testfile('simple_require.rb') {
      assert File.exists?(File.join(Vendorize.root_folder, 'no_loads.rb'))
    }
  end

  def test_can_specify_different_folder
    ENV['_Vendor_'] = './_different_'
    vendorize_testfile('simple_require.rb') {
      assert File.exists?(File.join('./_different_', 'no_loads.rb'))
    }
  end

  def test_should_cache_files_in_a_folder_heirarchy
    vendorize_testfile('deep_require.rb') {
      assert File.exists?(File.join(Vendorize.root_folder, 'no_loads.rb'))
      assert File.exists?(File.join(Vendorize.root_folder, 'testsub1/sub2/sub3/deep_file.rb'))
    }
  end

  def test_should_cache_from_standard_library
    rexml_expected = case Ruby.version
    when :mri185 then 31
    else 35
    end
    vendorize_testfile('library_user.rb') { |output|
      assert File.exists?(Vendorize.root_folder)
      vendored_files = files_in_cache
      assert_equal(rexml_expected, vendored_files.length, "Rexml should load #{rexml_expected} files (on my machine...)")
    }
  end
  
  def test_should_not_copy_files_on_second_pass
    rexml_expected = case Ruby.version
    when :mri185 then 31
    else 35
    end

    vendorize_testfile('library_user.rb') { |first_output|
      first_reported_cached = files_reported_cached(first_output)
      first_file_set = files_in_cache

      assert_equal(first_reported_cached.length, first_file_set.length, "The number of reported cached files should be the same as the number found")
      assert_equal(rexml_expected, first_file_set.length, "Rexml should load #{rexml_expected} files (on my machine...)")

      vendorize_file('./library_user.rb') { |second_output|
        second_reported_cached = files_reported_cached(second_output)
        second_vendored_files = files_in_cache
        
        assert_equal(first_file_set.length, second_vendored_files.length, "Number of files should not change")
        assert_equal(0, second_reported_cached.length, "No files should be cached 2nd time")       
      }
    }
  end

  def test_should_cache_gem_files
    expected = case Ruby.version
    when :mri185   then 53
    when :mingw186 then 55
    when :mingw187 then 63
    when :mingw191 then 43
    when :mingw192p0 then 46
    when :mingw192p180 then 23
    when :linux192 then 26
    when :jruby then    40
    when :jruby161 then 50
    when :ironruby then 45
    when :ironruby113 then 29
    else flunk("What version?")
    end

    vendorize_testfile('gem_require.rb') { |output|
      vendored_files = files_in_cache
      assert_equal(expected, vendored_files.length, "Should give #{expected} files (on my machine...)")
    }
  end

  def test_should_add_to_cache_incrementally
    rubygems_expected, plus_testunit, plusrake = case Ruby.version
    when :mri185   then [37, 55, 61]
    when :mingw186 then [37, 55, 62]
    when :mingw187 then [46, 63, 69]
    when :mingw191 then [37, 43, 49]
    when :mingw192p0 then [40, 46, 51]
    when :mingw192p180 then [16, 23, 30]
    when :linux192 then [19, 26, 33]
    when :jruby then    [22, 40, 47]
    when :jruby161 then [32, 50, 57]
    when :ironruby then [27, 45, 51]
    when :ironruby113  then [22, 29, 35]
    else flunk("What version?")
    end

    # First stage just requires rubygems
    ENV['TEST_STAGE'] = '1'
    vendorize_testfile('multi_require.rb') { |output|
      #ENV['keep_folder'] = '__test_should_add_to_cache_incrementally'
      vendored_files = files_in_cache
      assert_equal(rubygems_expected, vendored_files.length, "require rubygems should give #{rubygems_expected} files (on my machine...)")

      # Second stage adds test/unit
      ENV['TEST_STAGE'] = '2'
      vendorize_file('./multi_require.rb') { |output|
        vendored_files = files_in_cache
        assert_equal(plus_testunit, vendored_files.length, "adding test unit gives #{plus_testunit} files (on my machine...)")

        # Third stage adds rake
        ENV['TEST_STAGE'] = '3'
        vendorize_file('./multi_require.rb') { |output|
          vendored_files = files_in_cache
          assert_equal(plusrake, vendored_files.length, "adding rake gives #{plusrake} files (on my machine...)")

          # Fourth stage adds one local
          ENV['TEST_STAGE'] = '4'
          vendorize_file('./multi_require.rb') { |output|
            vendored_files = files_in_cache
            assert_equal(1 + plusrake, vendored_files.length, "adding multi gives #{1 + plusrake} files (on my machine...)")
          }
        }
      }
    }
  end

end
