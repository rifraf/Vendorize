require 'test/unit'
require 'fileutils'

# Pull in vendorize so we can get constants, but without
# doing the overrides. Otherwise we disrupt the test code...
ENV['NO_VENDORIZE'] = 'Testing'
require 'vendorize'
ENV['NO_VENDORIZE'] = nil

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'lib/rubies'

# Test helpers
module VendorizeTestSupport

  Vendorize_location = File.expand_path("./lib/vendorize.rb")

  def vendorize_file(name, &blk)
      output = `#{Ruby.exe} -w -r#{Vendorize_location} #{name}`
      begin
        blk.call(output) if block_given?
      ensure
        if File.exists?(Vendorize.root_folder)
          if ENV['keep_folder']
            FileUtils.cp_r(Vendorize.root_folder, ENV['keep_folder'])
          end
          FileUtils.rm_r Vendorize.root_folder
        end
      end
  end

  def vendorize_testfile(name, &blk)
    Dir.chdir("./test/testfiles") { |path|
      vendorize_file(name, &blk)
    }
  end
end

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

  def test_that_a_file_with_no_requires_creates_no_folder
    vendorize_testfile('no_loads.rb') {
      assert !File.exists?(Vendorize.root_folder)
    }
  end

  def test_a_file_with_a_simple_require
    vendorize_testfile('simple_require.rb') {
      assert File.exists?(Vendorize.root_folder)
      assert File.exists?(File.join(Vendorize.root_folder, 'no_loads.rb'))
    }
  end

  def test_a_file_with_a_deeper_path
    vendorize_testfile('deep_require.rb') {
      assert File.exists?(Vendorize.root_folder)
      assert File.exists?(File.join(Vendorize.root_folder, 'no_loads.rb'))
      assert File.exists?(File.join(Vendorize.root_folder, 'testsub1/sub2/sub3/deep_file.rb'))
    }
  end

  def test_a_file_requiring_a_library
    rexml_expected = case Ruby.version
    when :mri185 then 31
    when :mingw186 then 35
    when :mingw187 then 35
    when :mingw191 then 35
    when :linux192 then 35
    when :jruby then 35
    when :ironruby then 35
    else flunk("What version?")
    end
    vendorize_testfile('library_user.rb') { |output|
      assert File.exists?(Vendorize.root_folder)
      vendored_files = Dir["#{Vendorize.root_folder}/**/*"].select {|f| File.file?(f)}
      assert_equal(rexml_expected, vendored_files.length, "Rexml should load #{rexml_expected} files (on my machine...)")
    }
  end
  
  def test_second_pass_uses_cached_files
    rexml_expected = case Ruby.version
    when :mri185 then 31
    else 35
    end

    vendorize_testfile('library_user.rb') { |first_output|
      first_reported_cached = first_output.scan(/'.*?' cached to /)
      assert File.exists?(Vendorize.root_folder)
      first_file_set = Dir["#{Vendorize.root_folder}/**/*"].select {|f| File.file?(f)}

      assert_equal(first_reported_cached.length, first_file_set.length, "The number of reported cached files should be the same as the number found")
      assert_equal(rexml_expected, first_file_set.length, "Rexml should load #{rexml_expected} files (on my machine...)")

      vendorize_file('./library_user.rb') { |second_output|
        second_reported_cached = second_output.scan(/'.*?' cached to /)
        second_vendored_files = Dir["#{Vendorize.root_folder}/**/*"].select {|f| File.file?(f)}
        
        assert_equal(first_file_set.length, second_vendored_files.length, "Number of files should not change")
        assert_equal(0, second_reported_cached.length, "No files should be cached 2nd time")       
        ENV['keep_folder'] = '__savX1'
      }
      ENV['keep_folder'] = '__savX2'
    }
  end

  def test_gem_requires
    rubygems_expected, plus_testunit, plusrake = case Ruby.version
    when :mri185   then [36, 54, 59]
    when :mingw186 then [35, 53, 59]
    when :mingw187 then [36, 54, 59]
    when :mingw191 then [34, 40, 47]
    when :linux192 then [18, 25, 31]
    when :jruby then    [21, 39, 45]
    when :ironruby then [26, 44, 49]
    else flunk("What version?")
    end

    ENV['TEST_STAGE'] = '1'
    vendorize_testfile('gem_require.rb') { |output|
      ENV['keep_folder'] = '__sav'
      vendored_files = Dir["#{Vendorize.root_folder}/**/*"].select {|f| File.file?(f)}
      assert_equal(rubygems_expected, vendored_files.length, "require rubygems should give #{rubygems_expected} files (on my machine...)")

      ENV['TEST_STAGE'] = '2'
      vendorize_file('./gem_require.rb') { |output|
        vendored_files = Dir["#{Vendorize.root_folder}/**/*"].select {|f| File.file?(f)}
        assert_equal(plus_testunit, vendored_files.length, "adding test unit gives #{plus_testunit} files (on my machine...)")

        ENV['TEST_STAGE'] = '3'
        vendorize_file('./gem_require.rb') { |output|
#puts output
          vendored_files = Dir["#{Vendorize.root_folder}/**/*"].select {|f| File.file?(f)}
          assert_equal(plusrake, vendored_files.length, "adding rake gives #{plusrake} files (on my machine...)")
        }
      }
    }
  end

end
