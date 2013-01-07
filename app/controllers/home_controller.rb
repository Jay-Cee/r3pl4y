class HomeController < ApplicationController
  def index

		# Already authenticated, redirect
		if not current_user.nil? then
			redirect_to '/profile'
		end

    @users = User.order('created_at DESC').limit(5)
		@reviews = Review.order('created_at DESC').limit(5)
  end

end
