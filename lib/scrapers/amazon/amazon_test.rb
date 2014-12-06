require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './lib/scrapers/scraper.rb'
require './lib/scrapers/amazon/amazon_scraper.rb'

product_list = ['B00598N0WI','B004391DK0','B001ARYU58','B00K6ZIFAQ','B00D5Q75RC','B00H40T7GW','B0007LEG2K','B004HICPHW']
books = ['B00JYWUHO4', '032157351X','1476757801','1611099692','1438005008','0140280197','0545162076']

batch1 = AmazonScrape.new

batch1.scrape_products(product_list)






