require 'rubygems'
require 'nokogiri'
require 'open-uri'

html = open("http://www.cnn.com") { |io| data = io.read }

array = [1, 2, 3]

array.each do |num|
	puts html.size
end