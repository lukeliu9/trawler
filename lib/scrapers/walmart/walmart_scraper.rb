class WalmmartScrape < Scrape
	
	@@base = "http://www.walmart.com/"
	@@before_id = "ip/"
	@@after_id = ""
	@@product_attributes = {
		title: "heading-b.product-name.product-heading.js-product-heading",
		list_price: "span.price-details-list-price",
		price: "div.js-price-display.price.price-display",
		seller: "a.js-product-brand.product-brand",
		reviews_count: "",
		breadcrumb: "ol.breadcrumb-list.breadcrumb-list-mini",
		color_variant: "span.variant-swatch"

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