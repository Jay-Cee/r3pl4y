class HomeController < ApplicationController
  def index

		# Already authenticated, redirect
		if not current_user.nil? then
			redirect_to '/profile'
		end

		@reviews = Review.limit(3).order('random()')
  end

end
