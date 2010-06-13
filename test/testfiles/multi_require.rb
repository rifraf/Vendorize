puts __FILE__

def try_require(file)
  begin
    require file
  rescue LoadError
    puts "Could not load '#{file}'"
  end
end

puts "---------------------- rubygems #{ENV['TEST_STAGE']}"
try_require 'a'
require 'rubygems'
try_require 'x'
unless ENV['TEST_STAGE'] == '1'
  puts '---------------------- test/unit'
  require 'test/unit'
  unless ENV['TEST_STAGE'] == '2'
    puts '---------------------- rake'
    require 'rake'
    unless ENV['TEST_STAGE'] == '3'
      puts '---------------------- no_loads'
      require 'no_loads'
    end
  end
end
puts "---------------------- done #{ENV['TEST_STAGE']}"
puts __FILE__

