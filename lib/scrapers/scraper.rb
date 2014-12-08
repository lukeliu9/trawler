class Scrape

	def initialize(company)
		@products = {}
		@company = company
	end

	def get_css_attribute(html, doc)
		output = remove_html_tags(doc.css(html).to_s.strip)
		if output == "" || nil
			"N/A"
		else
			output
		end
	end

	def perform_css_scrape(html, doc, product, attribute)
		output = get_css_attribute(html, doc)
		@products[product][attribute] = output
	end

	def get_css_attribute_info(product, attributes, doc, key)
		@products[product] = {}
		@products[product][:type] = key
		attributes.each do |attribute, html|
			if html.kind_of?(Hash)
				html.each do |option, markup|
					if get_css_attribute(markup, doc) != nil
						perform_css_scrape(markup, doc, product, attribute)
						break
					end
				end
			else
				perform_css_scrape(html, doc, product, attribute)
			end
		end
	end

	def product_setup(attributes, product_id, base, before_id, after_id)
		url = "#{base}#{before_id}#{product_id}#{after_id}"  
		tries ||= 20
		# Amazon URL's randomly raise http 303 errors so trying them again after a pause is a good solution
		begin
			doc = Nokogiri::HTML(open(url))
		rescue OpenURI::HTTPError
			tries -= 1
			if tries > 0
				# puts "attempts remaining: #{tries}"
				sleep 3
		    	retry
			else
		   		puts "Failed too many times!"
			end
		else
			attributes.each do |key, value|
				# Loops through master product attributes hash to determine the product type and which nested hash to loop through
				if get_css_attribute(value[:identifier_tag], doc).include?(value[:identifier])
					get_css_attribute_info(product_id, value[:attributes], doc, key)
					break
				end
			end
		end
	end

	# Prints scrape info to console, for testing purposes
	def print_product_info
		@products.each do |product, attributes|
			puts "\n#{@company} ID: #{product}"
			attributes.each do |attribute, value|
				if attribute == "title" or attribute == "name"
					puts "   #{value}"
				else
					puts "\t -> #{attribute}: #{value}"
				end
			end
		end
	end

	def save_to_redis
	end

	# Helper methods

	def remove_html_tags(string)
	    re = /<("[^"]*"|'[^']*'|[^'">])*>/
	    string.gsub!(re, '')
	end

end