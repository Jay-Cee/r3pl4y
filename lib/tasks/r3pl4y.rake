namespace :r3pl4y do

  desc "Refresh facebook tokens"
  task :refresh_facebook_tokens => :environment do
    puts "START: Refresh facebook tokens"

    # expires within a week
    expiration = DateTime::now + 7

    # get soon to be expired users
    User.where('facebook_access_token_expires < ?', expiration).each do |user|

      # update token url
      url = "https://graph.facebook.com/oauth/access_token?client_id=#{ENV['facebook_app_id']}&client_secret=#{ENV['facebook_app_secret']}&grant_type=fb_exchange_token&fb_exchange_token=#{user.facebook_access_token}"
      
      begin
        puts "Renew token for #{user.id}/#{user.name}"
        data = open(url).read
        /expires=(?<expires>\d+)/ =~ data # get the seconds for expires

        user.facebook_access_token_expires = DateTime.now.advance(:seconds => expires.to_i)

      rescue Exception => e
        puts "Failed to update facebook expiration token for user #{user.id}/#{user.name}: #{e.message}"

        # remove user facebook expires
        user.facebook_access_token_expires = nil
      end

      user.save
    end

    puts "DONE: Refresh facebook tokens"
  end

	desc "Rebuild user scores"
	task :rebuild_score => :environment do
		User.all.each do |user|
			# reset score
			user.score = 0

			# ratings
			user.score += user.reviews.find_all{|review| review.rating}.length

			# reviews
			user.score += user.reviews.find_all{|review| not review.review.strip.empty?}.length * 5

			# connected providers
			user.score += user.facebook_auth? ? 10 : 0
			user.score += user.twitter_auth? ? 10 : 0
			user.score += user.steam_auth? ? 10 : 0

			puts "#{user.name}: #{user.score}"
			user.save
		end
	end

	desc "Rebuild the search index"
	task :rebuild_index => :environment do
		# truncate tables
		#sql = "SELECT id, title FROM games"
		#records = ActiveRecord::Base.connection.execute(sql)

		Game.all.each do |game|
			puts game.title

			# slugify the title
			slug = Game.create_slug(game.title)

			# get all words > 2 in length
			words = slug.split('-').find_all {|item| item.length > 2}

			words.each do |word|
				index = Word.find_by_word(word)

				if index
					game.words.push(index)
				else
					game.words.push(Word.create! :word => word)
				end
			end

			game.save
		end
		
	end
end
