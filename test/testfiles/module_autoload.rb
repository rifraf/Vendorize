$LOAD_PATH.unshift File.dirname(__FILE__)
puts __FILE__

# Module autoload is different from Kernel autoload
module Bar
  autoload :Foo, 'no_loads'
end
puts Bar::Foo
