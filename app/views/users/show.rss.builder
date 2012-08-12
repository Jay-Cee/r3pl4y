xml.instruct! :xml, :version => '1.0'
xml.rss "version" => "2.0" do
 xml.channel do
   xml.title "#{@user.name} reviews"
   xml.description "#{@user.name} r3pl4y reviews"
   xml.link user_url(@user)

   @user.reviews.each do |review|
     xml.item do
       xml.title "#{review.game.title} - #{review.rating}up"
			 xml.pubDate review.published.to_s(:rfc822)
       xml.link user_review_url(@user, review)
       xml.description markdown(review.review)
     end
   end

 end
end
