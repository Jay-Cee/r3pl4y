xml.instruct! :xml, :version => '1.0'
xml.rss "version" => "2.0" do
 xml.channel do
   xml.title "#{@game.title} reviews"
   xml.description "r3pl4y reviews for: #{@game.title}"
   xml.link game_url(@game)

   @game.reviews.each do |review|
     xml.item do
       xml.title "#{review.user.name} - #{review.rating}up"
			 xml.pubDate review.published.to_s(:rfc822)
       xml.link user_review_url(review.user, review)
       xml.description markdown(review.review)
     end
   end

 end
end
