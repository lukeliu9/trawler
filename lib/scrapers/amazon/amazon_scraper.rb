class AmazonScrape < Scrape
	
	@@base = "http://www.amazon.com/"
	@@before_id = "gp/product/"
	@@after_id = ""
	@@product_attributes = {
		title: "span#productTitle",
		list_price: "td.a-span12 a-color-secondary-a-size-base a-text-strike",
		price: "span#priceblock_ourprice",
		seller: "a#brand",
		reviews_count: "span#acrCustomerReviewText"
	}

	def get_product_price(html, doc)
		if get_attribute(html, doc) == nil
			get_attribute("b.priceLarge", doc)
		else
			get_attribute(html, doc)
		end
	end

	def scrape_products(products)
		products.each do |product|
			perform_scrape(@@product_attributes, product, @@base, @@before_id, @@after_id)
		end
	end

	def scrape_books(books)
	end

	def scrape_everything(list)
	end

end