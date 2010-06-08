$LOAD_PATH.unshift File.dirname(__FILE__)
puts __FILE__
require 'sub1/sub2/sub3/deep_file'
require 'no_loads'
puts __FILE__