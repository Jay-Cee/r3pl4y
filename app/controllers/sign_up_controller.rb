require 'digest'

class SignUpController < ApplicationController
  def index
		@invite = Invite.new
  end

	def new
		@invite = Invite.new(params[:invite])

		# check if already in line
		db_invite = Invite.where('email = :email AND user_id IS NULL', :email => @invite.email).first

		if db_invite
			redirect_to root_url, :alert => 'You\'re already in line for an invite. Patience, young padwan.'
			return false
		end


		@invite.hash = Digest::MD5.hexdigest(@invite.email)
		if @invite.save
			redirect_to url_for(:controller => 'home', :action => 'index'), :notice => 'You\'ve successfully been put in queue for invite.'

		else
			redirect_to url_for(:controller => 'home', :action => 'index'), :alert => 'An error occured during sign up process.'	
		end
	end
end
