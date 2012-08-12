class ProfileController < ApplicationController
	before_filter :authenticate_user!

	def timeline
		to = DateTime.parse(params['to']) if params['to']		
		from = params['from'] ? DateTime.parse(params['from']) : DateTime.now()
		@user = current_user	

		# Add r3pl4y relations
		twitter_uids = @user.friends.map {|f| f.twitter_uid}.compact
		facebook_uids = @user.friends.map {|f| f.facebook_uid}.compact
		steam_uids = @user.friends.map {|f| f.steam_uid }.compact
		r3pl4y_uids = @user.friends.map {|f| f.r3pl4y_uid}.compact | [@user.id]

		sql  = "(users.twitter_auth IN (:twitter_uids) OR "
		sql += "users.facebook_auth IN (:facebook_uids) OR "
		sql += "users.steam_auth IN (:steam_uids) OR "
		sql += "users.id IN (:r3pl4y_uids)) "
		sql += 'AND published <= :from '
		sql += 'AND published > :to ' if to

		data = {
			:twitter_uids => twitter_uids, 
			:facebook_uids => facebook_uids, 
			:steam_uids => steam_uids, 
			:r3pl4y_uids => r3pl4y_uids, 
			:from => from
		}

		data[:to] = to if to

		@reviews = Review.joins(:user).where(sql, data).order('published DESC').limit(11)

		respond_to do |format|
			format.text { render :partial => 'reviews/user_reviews.text.erb', :object => @reviews }
		end
	end

	def start
		respond_to do |format|
			format.text { render :layout => false }
		end
	end

	def index
		@user = current_user	

		@last_review = Review.where(:user_id => @user.id).order('id DESC').first
		@your_reviews = Review.where(:user_id => @user.id).order('published DESC')



		if @user.real_name then
			@name = @user.real_name
		else
			@name = @user.name
		end

		respond_to do |format|
			format.html { render :layout => 'profile' }
		end
	end

	def follow
		user = User.find_by_name(params[:name])

		if not current_user.following.any? {|u| u == user} then
			Friend.create :r3pl4y_uid => user.id, :user_id => current_user.id
		end

		response = { :href => url_for(:action => 'unfollow', :name => user.name), :class => 'unfollow' }

		respond_to do |format|
			format.json { render json: response }
		end
	end

	def unfollow
		user = User.find_by_name(params[:name])

		Friend.delete_all(:user_id => current_user.id, :twitter_uid => user.twitter_auth) unless user.twitter_auth.nil?
		Friend.delete_all(:user_id => current_user.id, :facebook_uid => user.facebook_auth) unless user.facebook_auth.nil?
		Friend.delete_all(:user_id => current_user.id, :steam_uid => user.steam_auth) unless user.steam_auth.nil?
		Friend.delete_all(:user_id => current_user.id, :r3pl4y_uid => user.id)

		response = { :href => url_for(:action => 'follow', :name => user.name), :class => 'follow' }

		respond_to do |format|
			format.json { render json: response }
		end
	end
end
