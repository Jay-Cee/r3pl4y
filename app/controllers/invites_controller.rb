class InvitesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :authenticate_admin

	def authenticate_admin
		if current_user.role != 'admin'
			raise "Unauthorized"
		end
	end

	def index
		@invites = Invite.all
	end
end
