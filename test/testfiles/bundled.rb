puts "#{__FILE__}:#{__LINE__}"
require "rubygems"
puts "#{__FILE__}:#{__LINE__}"
require "bundler"
puts "#{__FILE__}:#{__LINE__}"
Bundler.setup
puts "#{__FILE__}:#{__LINE__}"
require "nokogiri"
html_doc = Nokogiri::HTML("<html><body><h1>Mr. Belvedere Fan Club</h1></body></html>")
puts html_doc
puts "#{__FILE__}:#{__LINE__}"
