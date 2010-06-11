puts __FILE__
puts "---------------------- rubygems #{ENV['TEST_STAGE']}"
require 'rubygems'
unless ENV['TEST_STAGE'] == '1'
  puts '---------------------- test/unit'
  require 'test/unit'
  unless ENV['TEST_STAGE'] == '2'
    puts '---------------------- mocha'
    require 'mocha'
    unless ENV['TEST_STAGE'] == '3'
      puts '---------------------- rake'
      require 'rake'
    end
  end
end
puts "---------------------- done #{ENV['TEST_STAGE']}"
puts __FILE__


