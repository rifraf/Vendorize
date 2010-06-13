$LOAD_PATH.unshift File.dirname(__FILE__)
puts __FILE__
load 'no_loads.rb'
puts __FILE__