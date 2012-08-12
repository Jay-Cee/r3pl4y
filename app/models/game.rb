class Game < ActiveRecord::Base
	has_many :reviews, :order => "published DESC"
	has_many :game_tags
	has_many :tags, :through => :game_tags
	has_many :game_words
	has_many :words, :through => :game_words
	
	has_attached_file :thumbnail,
		:styles => {
			:medium => "160x",
      :small => "60x"
		},
		:storage => :aws,
		:s3_credentials => { 
			:access_key_id => ENV['s3_access_key_id'],
		  :secret_access_key => ENV['s3_secret_access_key'],
			:endpoint => 's3-eu-west-1.amazonaws.com' 
		},
		:s3_permissions => :public_read,
		:s3_protocol => 'http',
		:s3_options => {
		  :content_disposition => 'attachment'
		},
		:s3_bucket => 'files.r3pl4y.com',
    :s3_host_alias => 'files.r3pl4y.com',
    :s3_headers => {'Expires' => 1.year.from_now.httpdate},
		:path => ":attachment/:id/:style.:extension"
	
	has_attached_file :background,
		:styles => {
			:full => "800x600#"
		},
		:storage => :aws,
		:s3_credentials => { 
			:access_key_id => ENV['s3_access_key_id'],
		  :secret_access_key => ENV['s3_secret_access_key'],
			:endpoint => 's3-eu-west-1.amazonaws.com'
		},
		:s3_permissions => :public_read,
		:s3_protocol => 'http',
		:s3_options => {
		  :content_disposition => 'attachment'
		},
		:s3_bucket => 'files.r3pl4y.com',
    :s3_host_alias => 'files.r3pl4y.com',
    :s3_headers => {'Expires' => 1.year.from_now.httpdate},
		:path => ":attachment/:id/:style.:extension"




	attr_accessor :your_review, :other_reviews

	validates_uniqueness_of :slug

	def to_param
		slug
	end

	def discrete_average_rating
		if rate_average < 1.8 then
			return 1
		elsif rate_average < 2.6 then
			return 2
		elsif rate_average < 3.4 then
			return 3
		elsif rate_average < 4.2 then
			return 4
		else
			return 5
		end
	end

	def new_review
		Review.new :game_id => @id
	end

	def self.create_slug(title)
		title.downcase.gsub(/[^\w^\s^\d^-]/, '').gsub(/\s/, '-')
	end

	def platforms
		tags.find_all {|tag| tag.category == 'platform'}
	end

	def genres
		tags.find_all {|tag| tag.category == 'genre'}
	end

	def developers
		tags.find_all {|tag| tag.category == 'studio'}
	end

	def publishers
		tags.find_all {|tag| tag.category == 'publisher'}
	end
end

