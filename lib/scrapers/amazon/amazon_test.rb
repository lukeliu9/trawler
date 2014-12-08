require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './lib/scrapers/scraper.rb'
require './lib/scrapers/amazon/amazon_scraper.rb'

product_list = ['B00598N0WI','B004391DK0','B001ARYU58','B00K6ZIFAQ','B00D5Q75RC','B00H40T7GW','B0007LEG2K','B004HICPHW', 'B00IKPZ5V6', 'B0045UAEQG']
books = ['032157351X','1476757801','1611099692','1438005008','0140280197','0545162076']
kindle_books = ['B00JYWUHO4']

master_list = ['B00598N0WI', '1438005008', 'B004391DK0','B001ARYU58','B00K6ZIFAQ','B00D5Q75RC','B00H40T7GW','B0007LEG2K','B004HICPHW', 'B00JYWUHO4','032157351X','1476757801','1611099692','0140280197','0545162076']

quick = ['B00598N0WI']

batch1 = AmazonScrape.new("Amazon")

batch1.scrape_products(product_list)

batch1.print_product_info







# p doc.xpath(Nokogiri::CSS.xpath_for('span#productTitle'))
# string = doc.css('div.detailBreadcrumb').to_s.strip.gsub!(/<("[^"]*"|'[^']*'|[^'">])*>/, '').squish.split('›').map(&:strip)
# doc = Nokogiri::HTML(open("http://www.amazon.com/gp/product/B0045UAEQG/ref=s9_al_bw_g201_i5?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=merchandised-search-4&pf_rd_r=1BPMQVNB7NAQ309Q7YW7&pf_rd_t=101&pf_rd_p=1970352382&pf_rd_i=1057792"))

# irb(main):011:0> doc.css('table#histogramTable').to_s.strip.gsub!(/<("[^"]*"|'[^']*'|[^'">])*>/, '')
# => "\n  \n  \n    \n      5 star      \n    \n    \n      \n    \n    \n      96\n    \n  \n  \n  \n    \n      4 star      \n    \n    \n      \n    \n    \n      58\n    \n  \n  \n  \n    \n      3 star      \n    \n    \n      \n    \n    \n      48\n    \n  \n  \n  \n    \n      2 star      \n    \n    \n      \n    \n    \n      48\n    \n  \n  \n  \n    \n      1 star      \n    \n    \n      \n    \n    \n      55\n    \n  \n"


# string[27..string.length][/\d+/]