class Scrape

	def get_attribute(html, doc)
		remove_html_tags(doc.css(html).to_s.strip)
	end

	def print_product_info(products)
		products.each do |key, value|
			if key == "title"
				puts "\n#{value}"
			else
				puts "\t -> #{key}: #{value}"
			end
		end
	end

	def get_attribute_info(attributes, doc)
		product_hash = {}
		attributes.each do |attribute, html|
			output = get_attribute(html, doc)
			product_hash["#{attribute}"] = output
		end
		print_product_info(product_hash)
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

	def save_to_redis
	end

	def remove_html_tags(string)
	    re = /<("[^"]*"|'[^']*'|[^'">])*>/
	    string.gsub!(re, '')
	end

end