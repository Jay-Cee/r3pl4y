class Review < ActiveRecord::Base
	belongs_to :game
	belongs_to :user

	attr_accessor :share_twitter, :share_facebook

	# Gives a formatted string that describes when this review was published
	def published_from(now)
		timespan = now - published

		# If less than 60 seconds, say 'Now'
		if timespan < 60 then
			'Now'

		# If less than 60 minutes, say 'dd minutes ago'
		elsif timespan < 3600 then
			"#{(timespan / 60).to_i} minutes ago"

		# If less than 12 hours, say 'hh hours ago'
		elsif timespan < 43200 then
			"#{(timespan / 3600).to_i} hours ago"

		# If less than 24 hours and same day, say 'Today 12:34'
		elsif timespan < 86400 and now.day == published.day then
			published.strftime 'Today %H:%M'

		# If less than 48 hours and yesterday, say 'Yesterday 12:34'
		elsif timespan < 172800 and (now.day - 1) == published.day then
			published.strftime 'Yesterday %H:%M'

		# If less than 7 days, say 'Sunday 12:34'
		elsif timespan < 604800 then
			published.strftime '%A %H:%M'

		# Else say '18 January, 12:34'
		else
			published.strftime '%-d %B, %H:%M'
		end
	end

  # share this review to facebook
  def share_to_facebook!
		#get user
		user = User.find(user_id)

		begin
			graph = Koala::Facebook::API.new(user.facebook_access_token, ENV['facebook_app_secret'])

			logger.info "Facebook: User #{user.name} reviewing game #{Rails.application.routes.url_helpers.game_url(game, :host => 'replay.mikaellundin.name')}"

			result = graph.put_connections(
				"me", 
				"rubriks:review", 
				game: Rails.application.routes.url_helpers.game_url(game, :host => 'replay.mikaellundin.name'), 
				content: review, 
				rating: rating)

			logger.info "Successful facebook publish: #{result.to_yaml}"

		rescue Exception => exc
			logger.error "Failed to publish review #{id} to facebook #{user.facebook_auth}"
			logger.error "Facebook error msg: #{exc.message}"
		end
  end

	def trim(str, max_length)
		return str if str.length < max_length
		return str[0..max_length]
	end

  # share review to twitter
  def share_to_twitter!
		# get user
		user = User.find(user_id)

		# try
		begin
			# build message
			url = Rails.application.routes.url_helpers.user_review_url(user, self, :host => 'replay.mikaellundin.name')
			msg = "#{game.title}: #{trim(review, (95 - game.title.length))}... #r3pl4y #{url}"
			logger.debug "Updating twitter for (#{user.name}): #{msg}"

			# Could be a threading problem if two users are reviewing at the
			# same time, will update each others Twitter feeds
			Twitter.configure do |config|
				config.consumer_key = ENV['twitter_consumer_key']
				config.consumer_secret = ENV['twitter_consumer_secret']
				config.oauth_token = user.twitter_oauth_token
				config.oauth_token_secret = user.twitter_oauth_secret
			end
			Twitter.update(msg)

		rescue Exception => exc
			logger.error "Failed to publish review #{id} to twitter #{user.twitter_auth}"
			logger.error "Twitter error msg: #{exc.message}"
		end
  end
end
