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

	# called directly on the instance object to scrape a list of products based on their ID's. Grabs raw datat from hash and cleans into a hash for each product.
	def scrape_products(products)
		products.each do |product|
			product_setup(@@product_attributes, product, @@base, @@before_id, @@after_id)
		end
		clean_product_info
	end

	# loops through products scraped and determines what type they are to delegate to the appropriate data cleaning method.
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
		# 1) Takes the number of pages string and extracts the number
		attributes[:pages] = attributes[:pages][/\d+/].to_i
		# 2) Converting review counts to integers
		convert_ratings_to_int(attributes, ['five_star', 'four_star', 'three_star', 'two_star', 'one_star'])
	end

	def clean_book_info(product, attributes)
		attributes[:form_factor] = attributes[:form_factor].include?("Paperback") ? "Paperback" : "Hardcover"
	end

	def clean_default_info(product, attributes)
		# If a list price exists, calculate the discount of the actual price
		# list_price = attributes[:list_price].to_i
		# actual_price = attributes[:price].to_i
		# if list_price.nil?
		# 	attributes[:discount] = "N/A"
		# else
		# 	attributes[:discount] = (list_price - actual_price) / list_price
		# end

		# Takes the raw ratings histogram data and maps substrings to each star rating as a hash.
		all_ratings = attributes[:ratings].squish
		attributes.tap { |hs| hs.delete(:ratings) }
		match_default_star_ratings_counts(attributes, all_ratings, ['five_star', 'four_star', 'three_star', 'two_star', 'one_star'])
	end

	def match_default_star_ratings_counts(attributes, string, keys)
		i = 5
		keys.each do |key|
			attributes["#{key}".to_sym] = string[string.index("#{i} star")+7..string.length][/\d+/]
			i -= 1
		end
	end

	def convert_ratings_to_int(attributes, keys)
		keys.each do |key|
			attributes["#{key}".to_sym] = attributes["#{key}".to_sym].gsub(/,/, '').to_i
		end
	end

end










