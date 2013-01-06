xml.instruct! :xml, :version => '1.0'
xml.rss "version" => "2.0" do
 xml.channel do
   xml.title "R3PL4Y suggestions"
   xml.description "R3PL4Y game description suggestions"
   xml.link url_for(:controller => "suggestions", :action => "index")

   @suggestions.each do |suggestion|
     xml.item do
       xml.title "#{suggestion.game.title}"
			 xml.pubDate suggestion.created_at.to_s(:rfc822)
       xml.link preview_suggestion_path(suggestion, :only_path => false)
       xml.description markdown(suggestion.description) 
     end
   end
 end
end
