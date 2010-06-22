$LOAD_PATH.unshift File.dirname(__FILE__)
puts __FILE__

puts "---------------------- test/unit #{ENV['TEST_STAGE']}"
require 'test/unit'

unless ENV['TEST_STAGE'] == '1'
  puts '---------------------- testrunner.rb'
  Vendorize.add_requirable('test/unit/ui/tk/testrunner')

  unless ENV['TEST_STAGE'] == '2'
    puts '---------------------- rake'
    Vendorize.add('test/unit/ui/fox/testrunner.rb')

    unless ENV['TEST_STAGE'] == '3'
      puts '---------------------- no_loads'
      Vendorize.add_dir('test/unit')
    end
  end
end
puts "---------------------- done #{ENV['TEST_STAGE']}"
puts __FILE__

