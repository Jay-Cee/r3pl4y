module ApplicationHelper
	def body_classes
	  @body_classes ||= [controller.controller_name]
	end

	def title(page_title)
		content_for(:title) { page_title }
	end 

	def markdown(text)
		markdown = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, :autolink => true, :space_after_headers => true, :filter_html => true, :no_styles => true)
		markdown.render(text).html_safe
	end

	def plain(text)
		# remove all html tags
		result = strip_tags(text)

		# images, remove them
		result = result.gsub(/!\[.*?\]\(.*?\)/, '')
		
		# links, exchange with plain text
		result = result.gsub(/\[(.*?)\]\(.*?\)/, '\1')

		# paragraphs, create paragraphs on new line
		result = result.split(/[\n\r]+/).collect{|p| "<p>#{p}</p>"}.join("\n")

		return result.html_safe
	end
end
