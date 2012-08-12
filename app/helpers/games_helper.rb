module GamesHelper
	# only output title if not empty
	def tag_link(tag, options)
		if options.has_key?(:title) and options[:title].empty? then
			options.delete(:title)
		end

		link_to(tag.name, tag, options)
	end
end
