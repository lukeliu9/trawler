module TagScraper

	def remove_html_tags
	    re = /<("[^"]*"|'[^']*'|[^'">])*>/
	    self.gsub!(re, '')
	end

end	