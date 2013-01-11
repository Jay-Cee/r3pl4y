class User < ActiveRecord::Base
	has_many :reviews, :order => "id DESC"
	has_many :friends

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :timeoutable, :timeout_in => 30.days

	validates_presence_of :name
	validates_uniqueness_of :name, :case_sensitive => false

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

	def to_param
		name
	end

	def self.create_with_omniauth(auth, invited_by)
		logger.debug "oauth response: #{auth.to_yaml}"
		puts "oauth response: #{auth.to_yaml}"

		case auth['provider']
			when 'twitter'
				name = get_name(auth["info"]["nickname"])
				result = create! do |user|
					user.name = name
					user.real_name = auth['info']['name']
					user.password = Devise.friendly_token[0,20]
					user.twitter_auth = auth["uid"]
					user.email = "#{name}#{auth['uid']}@r3pl4y.com"
					user.picture = auth['info']['image']
					user.friends = get_tw_friends(auth["info"]["nickname"]) | [(Friend.create :r3pl4y_uid => invited_by)]
					user.invited_by = invited_by
			end

			when 'facebook'
				name = get_name(auth['info']['name'].gsub(/[^\w]/, '').downcase)
				
				create! do |user|
					user.name = name
					user.real_name = auth['info']['name']
					user.password = Devise.friendly_token[0,20]
					user.facebook_auth = auth["uid"]
					user.email = "#{name}#{auth['uid']}@r3pl4y.com"
					user.picture = auth['info']['image']
					user.friends = get_fb_friends(auth["credentials"]["token"]) | [(Friend.create :r3pl4y_uid => invited_by)]

					user.invited_by = invited_by
				end

			when 'steam'
				name = get_name(auth["info"]["nickname"].gsub(/[^\w]/, '').downcase)
				create! do |user|
					user.name = name
					user.real_name = auth['info']['name']
					user.password = Devise.friendly_token[0,20]
					user.steam_auth = auth["uid"]
					user.email = "#{name}#{auth['uid']}@r3pl4y.com"
					user.picture = auth['info']['image']
					user.friends = [] | [(Friend.create :r3pl4y_uid => invited_by)]
					user.invited_by = invited_by
				end

			else
				raise "Unknown provider #{auth['provider']}"
		end
	end

	def self.get_name(name)
		unique_name = name
		i = 1
		loop {
			user = User.find_by_name(unique_name)
			if user then
				unique_name = "#{unique_name}#{i += 1}"
			else
				return unique_name
			end
		}
	end

	def self.get_fb_friends(token)
		graph = FbGraph::User.new('me', :access_token => token)
		graph = graph.fetch
		graph.friends.map {|facebook_friend| Friend.create :facebook_uid => facebook_friend.identifier }
	end

	def self.get_tw_friends(name)
		Twitter.friend_ids(name)['ids'].map {|twitter_uid| Friend.create :twitter_uid => twitter_uid }
	end

	def merge(user)
		# start transaction
		ActiveRecord::Base.transaction do

			#move all reviews
			ActiveRecord::Base.connection.execute "UPDATE reviews SET user_id=#{id} WHERE user_id=#{user.id}"

			#move all friends
			ActiveRecord::Base.connection.execute "UPDATE friends SET user_id=#{id} WHERE user_id=#{user.id}"

			# delete old user
			ActiveRecord::Base.connection.execute "DELETE FROM users WHERE id=#{user.id}"
		end
	end

	def following
		twitter_uids = friends.map {|f| f.twitter_uid}.compact
		facebook_uids = friends.map {|f| f.facebook_uid}.compact
		steam_uids = friends.map {|f| f.steam_uid }.compact
		r3pl4y_uids = friends.map {|f| f.r3pl4y_uid }.compact

		User.where('twitter_auth IN (:twitter_uids) OR facebook_auth IN (:facebook_uids) OR steam_auth IN (:steam_uids) OR id IN (:r3pl4y_uids)',
			{ :twitter_uids => twitter_uids, :facebook_uids => facebook_uids, :steam_uids => steam_uids, :r3pl4y_uids => r3pl4y_uids}).order('name ASC').uniq
	end

	def followers
		twitter_uids = friends.map {|f| f.twitter_uid}.compact
		facebook_uids = friends.map {|f| f.facebook_uid}.compact
		steam_uids = friends.map {|f| f.steam_uid }.compact
		r3pl4y_uids = friends.map {|f| f.r3pl4y_uid }.compact

		User.joins(:friends).where('(:twitter_auth IS NOT NULL AND friends.twitter_uid = :twitter_auth) OR (:facebook_auth IS NOT NULL AND friends.facebook_uid = facebook_auth) OR (:steam_auth IS NOT NULL AND friends.steam_uid = :steam_auth) OR (friends.r3pl4y_uid = :r3pl4y_id)',
			{ :twitter_auth => twitter_auth, :facebook_auth => facebook_auth, :steam_auth => steam_auth, :r3pl4y_id => id }).order('name ASC').uniq
	end

	def invite_phrase
		passwords = ['element-zero', 'power-up', 'monster-kill', 'frags', '1up', 'credits', 'ninja-loot', 'leroy-jenkins', 'boss-rush', 'zerg-rush', 'bfg-2000', 'l2p', 'p0wned', 'mankriks-wife', 'larry-missing-floppies', 'threepwood-mighty-pirate', 'arrow-to-the-knee', 'fus-ro-dah', 'i-am-error', 'cake-is-a-lie']

		return passwords[id % passwords.length]
	end

	def has_rated?(game)
		reviews.any?{|review| review.game == game}
	end

	def last_review_of(game)
		reviews.find{|review| review.game == game}
	end
end
