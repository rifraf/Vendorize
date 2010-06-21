$LOAD_PATH.unshift File.dirname(__FILE__)
puts __FILE__

puts __LINE__
autoload :Bar, 'no_loads.rb'
puts __LINE__
puts autoload?(:Bar)
puts __LINE__
puts Bar::Foo
puts __LINE__
puts __FILE__