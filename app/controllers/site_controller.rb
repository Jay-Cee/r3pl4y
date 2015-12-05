class SiteController < ApplicationController
	caches_page :tumblr

	def index
		respond_to do |format|
			format.xml { render :layout => false }
		end
	end

	def tumblr
    # encoding: UTF-8
		require 'open-uri'
		require 'json'

		name = 'r3pl4ycom.tumblr.com'
		api_key = ENV['tumblr_api_key']
    uri = "http://api.tumblr.com/v2/blog/#{name}/posts/text?api_key=#{api_key}&limit=1"

    # get tumblr post
		json = open(uri).read

    # remove &nbsp;
    json = json.gsub('\u00a0', ' ')

		@content = JSON.parse json

		respond_to do |format|
			format.text { render :layout => false }
		end
	end
end
