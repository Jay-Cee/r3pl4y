namespace :r3pl4y do

  desc 'Captures a heroku backup.'
  task :backup do
    # capture the backup bundle
    timestamp = `date -u '+%Y%m%d%H%M'`.chomp
    bundle_name = "r3pl4y-#{timestamp}"
    puts "Capturing bundle #{bundle_name}..."
    `heroku pgbackups:capture --expire`

    # initialize Amazon S3
    s3 = AWS::S3.new(
      :access_key_id     => ENV['s3_access_key_id'],
      :secret_access_key => ENV['s3_secret_access_key'],
      :s3_endpoint => 's3-eu-west-1.amazonaws.com')

    bucket = s3.buckets['files.r3pl4y.com']

    # download & destroy the bundle we just captured
    puts "Downloading bundle #{bundle_name}.dump"
    backup_url = `heroku pgbackups:url`
    `curl -o '#{bundle_name}'.dump '#{backup_url}'`

    # copy backup to AWS S3
    puts "Moving bundle to AWS backup/#{bundle_name}.dump"
    obj = bucket.objects["backup/#{bundle_name}.dump"]
    obj.write(Pathname.new("#{bundle_name}.dump"))

    # remove backup
    `rm '#{bundle_name}'.dump`
  end



  desc "Refresh facebook tokens"
  task :refresh_facebook_tokens => :environment do
    puts "START: Refresh facebook tokens"

    # expires within a week
    expiration = DateTime::now + 14

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
        user.facebook_access_token = nil
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
    Game.find_in_batches do |games|
      game_ids = games.map {|game| game.id}
      Delayed::Job.enqueue(RecreateSearchIndexJob.new(game_ids))
    end
	end
end
