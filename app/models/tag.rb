class Tag < ActiveRecord::Base
	has_many :game_tags
	has_many :games, :through => :game_tags

	# Since a company can be both publisher and studio this is not possible
	#validates_uniqueness_of :name
	
	#def to_param
	#	name.downcase
	#end

	# case insensitive find_by_name
	def self.find_by_name(name)
		return Tag.where('UPPER(name) = UPPER(?)', name).first
	end

end
