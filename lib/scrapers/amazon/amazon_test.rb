require 'rubygems'
require 'nokogiri'
require 'open-uri'

product_list = ['B00598N0WI','B004391DK0','B001ARYU58','B00K6ZIFAQ','B00D5Q75RC','B00H40T7GW','B0007LEG2K','B004HICPHW']
books = ['B00JYWUHO4', '032157351X','1476757801','1611099692','1438005008','0140280197','0545162076']

module Detagger
	public

	def remove_html_tags
	    re = /<("[^"]*"|'[^']*'|[^'">])*>/
	    self.gsub!(re, '')
	end
end

class Scrape

	include Detagger

	def get_attribute(html, doc)
		doc.css(html).to_s.strip.remove_html_tags
	end

	def print_product_info(title, price)
		puts "#{title} - #{price}"
	end

	def get_attribute_info(attributes, doc)
		title = get_attribute(attributes[:title], doc)
		price = get_attribute(attributes[:price], doc)
		print_product_info(title, price)
	end

	def perform_scrape(attributes, product_id, base, before_id, after_id)
		url = "#{base}#{before_id}#{product_id}#{after_id}"  
		tries ||= 5
		# Amazon URL's randomly raise http 303 errors so trying them again after a pause is a good solution
		begin
			doc = Nokogiri::HTML(open(url))
		rescue OpenURI::HTTPError
			tries -= 1
			if tries > 0
				sleep 5
		    	retry
			else
		   		logger.info "Failed too many times!"
			end
		else	
			get_attribute_info(attributes, doc)
		end
	end
end

class AmazonScrape < Scrape
	
	@@base = "http://www.amazon.com/"
	@@before_id = "gp/product/"
	@@after_id = ""
	@@attributes = {
		title: "span#productTitle",
		price: "span#priceblock_ourprice"
	}

	def get_product_price(html, doc)
		if get_attribute(html, doc) == nil
			get_attribute("b.priceLarge", doc)
		else
			get_attribute(html, doc)
		end
	end

	def scrape(products)
		products.each do |product|
			perform_scrape(@@attributes, product, @@base, @@before_id, @@after_id)
		end
	end
end


batch1 = AmazonScrape.new

batch1.scrape(product_list)






