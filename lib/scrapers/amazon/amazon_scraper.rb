class AmazonScrape < Scrape
	
	@@base = "http://www.amazon.com/"
	@@before_id = "gp/product/"
	@@after_id = ""
	@@product_attributes = {
		book: {
			type: "book",
			identifier_tag: "li.nav-subnav-item.nav-category-button > a",
			identifier: "Books",
			attributes: {
				title: "span#productTitle",
				author: {
						a: "span.author > a",
						b: "span.author > span.a-declarative > a"
					},
				form_factor: "h1#title.a-size-large.a-spacing-none > span.a-size-medium.a-color-secondary.a-text-normal",
				release_date: "h1#title.a-size-large.a-spacing-none > span.a-size-medium.a-color-secondary.a-text-normal",
				# kindle_price: "",
				# paperback_price: "",
				# hardcover_price: "",
				# avg_review_rating: "",
				# reviews_count: ""
			},
			# xpath: {
			# 	five_star: "div.fl.histoRowfive > a > div.histoCount",
			# 	four_star: "div.fl.histoRowfour > a > div.histoCount",
			# 	three_star: "div.fl.histoRowthree > a > div.histoCount",
			# 	two_star: "div.fl.histoRowtwo > a > div.histoCount",
			# 	one_star: "div.fl.histoRowone > a > div.histoCount"
			# }
		},
		kindle_book: {
			type: "kindle",
			identifier_tag: "li.nav-subnav-item.nav-category-button > a",
			identifier: "Kindle",
			attributes: {
				title: "span#btAsinTitle",
				author: "a#contributorNameTriggerB000AQ40M8B00JYWUHO4",
				pages: "a#pageCountAvailable",
				five_star: "div.fl.histoRowfive > a > div.histoCount",
				four_star: "div.fl.histoRowfour > a > div.histoCount",
				three_star: "div.fl.histoRowthree > a > div.histoCount",
				two_star: "div.fl.histoRowtwo > a > div.histoCount",
				one_star: "div.fl.histoRowone > a > div.histoCount"
			},
			# xpath: {

			# }
		},
		default: {
			type: "default",
			identifier_tag: "span#acrCustomerReviewText",
			identifier: "reviews",
			attributes: {
				name: "span#productTitle",
				list_price: "td.a-span12.a-color-secondary.a-size-base.a-text-strike",
				price: "span#priceblock_ourprice",
				seller: "a#brand",
				availability: {
						a: "div.buying > span.availGreen",
						b: "div#availability > span.a-size-medium.a-color-success"
					},
				breadcrumb: "div.detailBreadcrumb",
				ratings: "table#histogramTable"
				# avg_review_rating: "",
			},
			# xpath: {

			# }
		}
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
			product_setup(@@product_attributes, product, @@base, @@before_id, @@after_id)
		end
		clean_product_info
	end

	def clean_product_info
		@products.each do |product, attributes|
			p attributes[:type]
			case attributes[:type]
			when :book
				clean_book_info(product, attributes)
			when :kindle_book
				clean_kindle_info(product, attributes)
			else
				clean_default_info(product, attributes)
			end
		end
	end

	def clean_kindle_info(product, attributes)
		attributes[:pages] = attributes[:pages][/\d+/].to_i
		# Converting review counts to integers
		attributes[:five_star] = attributes[:five_star].gsub(/,/, '').to_i 
		attributes[:four_star] = attributes[:four_star].gsub(/,/, '').to_i 
		attributes[:three_star] = attributes[:three_star].gsub(/,/, '').to_i 
		attributes[:two_star] = attributes[:two_star].gsub(/,/, '').to_i 
		attributes[:one_star] = attributes[:one_star].gsub(/,/, '').to_i  
	end

	def clean_book_info(product, attributes)
		attributes[:form_factor] = attributes[:form_factor].include?("Paperback") ? "Paperback" : "Hardcover"
	end

	def clean_default_info(product, attributes)
		# list_price = attributes[:list_price].to_i
		# actual_price = attributes[:price].to_i
		# if list_price.nil?
		# 	attributes[:discount] = "N/A"
		# else
		# 	attributes[:discount] = (list_price - actual_price) / list_price
		# end
		all_ratings = attributes[:ratings].squish
		attributes[:ratings][:five_star] = all_ratings[all_ratings.index('5 star')+7..all_ratings.length][/\d+/]
		attributes[:ratings][:four_star] = all_ratings[all_ratings.index('4 star')+7..all_ratings.length][/\d+/]
		attributes[:ratings][:three_star] = all_ratings[all_ratings.index('3 star')+7..all_ratings.length][/\d+/]
		attributes[:ratings][:two_star] = all_ratings[all_ratings.index('2 star')+7..all_ratings.length][/\d+/]
		attributes[:ratings][:one_star] = all_ratings[all_ratings.index('1 star')+7..all_ratings.length][/\d+/]
	end

end










