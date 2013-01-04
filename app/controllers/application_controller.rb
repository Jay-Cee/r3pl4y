class ApplicationController < ActionController::Base
  protect_from_forgery
	before_filter :store_location

	def store_location
		if params[:controller] == 'reviews' then
			session[:user_return_to] = request.url 
		elsif params[:controller] == 'devise/sessions' or params[:controller] == 'omniauth_callbacks' then
			# do nothing
		else
			session[:user_return_to] = nil
		end 
	end

	def after_sign_in_path_for(resource)
        params = request.env['omniauth.params']
        redirect_url = params['redirect_url'] unless params.nil?
        
		return redirect_url || request.env['omniauth.origin'] || stored_location_for(resource) || '/profile'
	end

  def authenticate_admin!
    render(:text => "Forbidden", :status => 403) unless current_user and current_user.role == "admin"
  end

end
