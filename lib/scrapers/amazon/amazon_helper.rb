class Amazon

	@@base = 'http://www.amazon.com/'

	def get_attribute(html, doc)
		doc.css(html).to_s.strip.remove_html_tags
	end

	def get_product_price(html, doc)
		if get_attribute(html, doc) == nil
			get_attribute("b.priceLarge", doc)
		else
			get_attribute(html, doc)
		end
	end

	def get_price(product_id)
		url = "#{base}gp/product/#{product_id}/ref=s9_simh_gw_p147_d0_i3?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=desktop-4&pf_rd_r=0AMH73YHPKJMN1TX4S26&pf_rd_t=36701&pf_rd_p=1970567742&pf_rd_i=desktop"  
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
			title = get_attribute("span#productTitle", doc)
			price = get_product_price("span#priceblock_ourprice", doc)

			puts "#{title} - #{price}"
		end
	end

end

