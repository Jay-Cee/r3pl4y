xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do	
	Review.all.each do |review|
		xml.url do
			xml.loc user_review_url(review.user, review)
			xml.lastmod review.updated_at.utc.strftime("%Y-%m-%d")
			xml.priority '0.8'
	 end
 end
end
