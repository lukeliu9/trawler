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
		calculate_pages(attributes)
		# 2) Converting review counts to integers
		convert_ratings_to_int(attributes, ['five_star', 'four_star', 'three_star', 'two_star', 'one_star'])
	end

	def clean_book_info(product, attributes)
		# 1) Decide if the book is paperback or hardcover
		attributes[:form_factor] = attributes[:form_factor].include?("Paperback") ? "Paperback" : "Hardcover"
		# 2) Extract release date
		
	end

	def clean_default_info(product, attributes)
		# 1) Takes the raw ratings histogram data and maps substrings to each star rating as a hash.
		match_default_star_ratings_counts(attributes, ['five_star', 'four_star', 'three_star', 'two_star', 'one_star'])
		# 2) Loop through raw text in the breadcrumb on the product page and dynamically create categorizations based on number of levels found
		set_product_categorization(attributes)
		# 3) Cleans availiability text
		clean_availability_text(attributes)
		# 4) Calculate discount from list price and sale price
		calculate_discount(attributes)
	end

	def match_default_star_ratings_counts(attributes, keys)
		string = attributes[:ratings].squish
		attributes.tap { |hs| hs.delete(:ratings) }
		i = 5
		keys.each do |key|
			attributes["#{key}".to_sym] = string[string.index("#{i} star")+7..string.length][/\d+/]
			i -= 1
		end
	end

	def set_product_categorization(attributes)
		if attributes[:breadcrumb].nil?
			attributes[:breadcrumb] = "N/A"
		else
			cat_array = attributes[:breadcrumb].squish.split('›').map(&:strip)
			attributes.tap { |hs| hs.delete(:breadcrumb) }
			i = 1
			cat_array.each do |string|
				attributes["cat_level_#{i}".to_sym] = string.gsub(/&amp;/, '&')
				i += 1
			end
		end
	end

	def clean_availability_text(attributes)
		if attributes[:availability].nil?
			attributes[:availability] = "N/A"
		else
			string = attributes[:availability]
			attributes[:availability] = string.strip.gsub('.', '')
		end
	end

	def calculate_discount(attributes)
		list = attributes[:list_price].nil? ? nil : attributes[:list_price].gsub('$','').to_i
		sale = attributes[:price].gsub('$','').to_i
		if list == nil
			discount = "N/A"
		else
			discount = (list.to_f - sale.to_f) / list.to_f
			discount = discount.round(4)
		end
		attributes[:discount] = discount
	end

	def calculate_pages(attributes)
		if attributes[:pages].nil?
			attributes[:pages] = "N/A"
		else
			attributes[:pages] = attributes[:pages][/\d+/].to_i
		end
	end

	def convert_ratings_to_int(attributes, keys)
		keys.each do |key|
			attributes["#{key}".to_sym] = attributes["#{key}".to_sym].gsub(/,/, '').to_i
		end
	end

end










