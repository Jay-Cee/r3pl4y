class UsersController < ApplicationController

  def show
    @user = User.find_by_name(params[:id])
		from = params['from'] ? DateTime.parse(params['from']) : DateTime.now()


		@reviews = Review.joins(:user).where("users.name = :name AND published <= :from", :name => @user.name, :from => from).order('published DESC').limit(11)	

		respond_to do |format|
      if current_user
        format.html { render :layout => 'profile' }
        format.text { render :layout => false }
        format.rss { render :layout => false }
      else
        format.html # show.html.erb
        format.text { render :layout => false }
        format.rss { render :layout => false }
      end
		end
  end

	def following_template
		@user_name = params[:name]
	end

	def followers_template
		@user_name = params[:name]
	end

	def following
		user = User.find_by_name(params[:name])
		
		respond_to do |format|
			format.text { render :partial => 'user_list', :object => user.following }
		end
	end

	def followers
		user = User.find_by_name(params[:name])

		respond_to do |format|
			format.text { render :partial => 'user_list', :object => user.followers }
		end
	end

	def stats
		@user = User.find_by_name(params[:name])

		# get number of ratings
		@quantity = Review.where("user_id = :user_id AND rating > 0", { :user_id => @user.id }).count

		# not much of statistics if @quantity is 0
		if @quantity == 0
			flash[:alert] = 'No statistics for you'
			return render :partial => 'layouts/notice.html.erb'
		end

		# get average rating
		@average = Review.where("user_id = :user_id AND rating > 0", { :user_id => @user.id }).average('rating')

		# count number of reviews in each rating
		@ratings = []
		(1..5).each do |rating|
			@ratings[rating] = Review.where(:user_id => @user.id, :rating => rating).count
		end

		respond_to do |format|
			format.text # stats.text.erb
		end
	end

	def lists
		@user_name = params[:name]
		@rating = params[:rating]

		respond_to do |format|
			format.text
		end
	end

	def invite
		user = User.find_by_name(params[:name])
		invite_phrase = params[:invite_phrase]
		hash = params[:hash]

		if user.invite_phrase != invite_phrase
			redirect_to root_url, :alert => 'Your invite url was invalid'
		else
			session[:invite] = user.id
			redirect_to '/users/sign_in', :notice => "You're being invited by #{user.name}"
		end
		return false
	end
end
