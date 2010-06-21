$LOAD_PATH.unshift File.dirname(__FILE__)

require 'test/unit'
require 'lib/rubies'
require 'lib/test_support'

# Pull in vendorize so we can get constants, but without
# doing the overrides. Otherwise we disrupt the test code...
ENV['NO_VENDORIZE'] = 'Testing'
require 'vendorize'
ENV['NO_VENDORIZE'] = nil


class TestSkips < Test::Unit::TestCase

  def test_skips_files_that_wont_cache
    assert(Vendorize.skip?('./boo.rb'))
    assert(Vendorize.skip?('../boo.rb'))
    assert(Vendorize.skip?('~/fred'))
    assert(Vendorize.skip?('c:\\ethel'))
  end

end
