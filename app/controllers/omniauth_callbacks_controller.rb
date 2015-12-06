class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	protect_from_forgery :except => [:twitter,:facebook,:steam]

  def twitter
			logger.debug "Called twitter callback"
            
			auth = request.env['omniauth.auth']
            params = request.env['omniauth.params']

			@user = User.find_by_twitter_auth(auth['uid'])

			# if not logged in and user not found
			if current_user.nil? and @user.nil? then
				@user = User.create_with_omniauth(auth, params['follow'])
				@user.save

			# adding new identity provider
			elsif not current_user.nil? and @user.nil? then
				@user = current_user
				@user.twitter_auth = auth['uid']
				@user.friends = @user.friends | User.get_tw_friends(auth['info']['nickname'])
				@user.save

			# merging two accounts
			elsif not current_user.nil? and not @user.nil? and current_user != @user then
				current_user.merge(@user)
				@user = current_user
				@user.twitter_auth = auth['uid']
				
				@user.save
			end

			# for twitter publishing, update when expired
			if @user.twitter_oauth_token != auth['credentials']['token'] or @user.twitter_oauth_secret != auth['credentials']['secret']

				@user.twitter_oauth_token = auth['credentials']['token']
				@user.twitter_oauth_secret = auth['credentials']['secret']

				@user.save
			end

			#flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
			sign_in_and_redirect @user, :event => :authentication
  end

	def facebook
			logger.debug 'Called facebook callback'

			auth = request.env['omniauth.auth'];
            params = request.env['omniauth.params']
			@user = User.find_by_facebook_auth(auth['uid'])

			# if not logged in and user not found
			if current_user.nil? and @user.nil? then
				@user = User.create_with_omniauth(auth, params['follow'])

			# adding new identity provider
			elsif not current_user.nil? and @user.nil? then
				@user = current_user
				@user.facebook_auth = auth['uid']
				@user.friends = @user.friends | User.get_fb_friends(auth['credentials']['token'])

			# merging two accounts
			elsif not current_user.nil? and not @user.nil? and current_user != @user then
				current_user.merge(@user)
				@user = current_user
				@user.facebook_auth = auth['uid']

			end

			@user.facebook_access_token = auth['credentials']['token']
			@user.facebook_access_token_expires = Date.strptime("#{auth['credentials']['expires_at']}", '%s')
			@user.save

			flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
			sign_in_and_redirect @user, :event => :authentication
	end

	def steam
			logger.debug 'Called steam callback'

			auth = request.env['omniauth.auth']
            params = request.env['omniauth.params']
			@user = User.find_by_steam_auth(auth['uid'])

			# if not logged in and user not found
			if current_user.nil? and @user.nil? then
				@user = User.create_with_omniauth(auth, params['follow'])
				@user.save

			# adding new identity provider
			elsif not current_user.nil? and @user.nil? then
				steam_user = User.create_with_omniauth(auth, params['follow'])

				@user = current_user
				@user.steam_auth = auth['uid']
				@user.friends = @user.friends | steam_user.friends
				@user.save

			# merging two accounts
			elsif not current_user.nil? and not @user.nil? and current_user != @user then
				current_user.merge(@user)
				@user = current_user
				@user.steam_auth = auth['uid']
				@user.save

			end

			flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Steam"
			sign_in_and_redirect @user, :event => :authentication
	end
end
