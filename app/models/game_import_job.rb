require 'csv'
require 'tempfile'
require 'aws/s3'

class GameImportJob < Struct.new(:path, :platform)

  def perform
    logger = Rails.logger

    # establish s3 connection
    logger.debug "Open connection to S3"
    s3 = AWS::S3.new

    # application bucket
    bucket_name = 'replay-files.mikaellundin.name'

    # fetch file from s3
    logger.debug "Fetch import file from S3: #{path}"
    object = s3.buckets[bucket_name].objects[path]
    file = Tempfile.new('import', Rails.root.join('tmp'))
    contents = object.read.force_encoding('utf-8')
    logger.debug "Object contents: #{contents}"
    file.write(contents)
    file.rewind

		CSV.foreach(file, :headers => true) do |row|
			# if ignore, then jump to next row
			next unless row[10].nil? or row[10].empty?

			# the game imported
			game = Game.new 
			game.is_public = true

			# get by id
			id = row[0]
			game = Game.find(id.to_i) unless id.nil?

			# get title and slug
			title = row[1]
			# move any ', The' at end to front
			title = "The #{title.gsub(/,\s?the$/i, '')}" if /,\s?the$/i.match(title)

			game.title = title
			game.slug = Game.create_slug(game.title)

			# get by slug and platform
		  if Game.exists?(:slug => game.slug)
				db_game = Game.find_by_slug(game.slug)

				# contains import platform, probably same game
				if db_game.platforms.find_all {|tag| tag.name == platform}.length > 0
					game = db_game

				# create a new game unpublished
				else
					game.slug = "#{game.slug}-#{Time.now.usec}"
					game.is_public = false
				end
			end

			# add genres
			if row[2]
				new_tags(row[2], 'genre').each do |genre|
					game.tags.push(genre) unless game.tags.include?(genre)
				end
			end

			# released
			game.released = Date.parse(row[3]) if row[3]

			# add developers
			if row[4]
				new_tags(row[4], 'studio').each do |developer|
					game.tags.push(developer) unless game.tags.include?(developer)
				end
			end

			# add publishers
			if row[5]
				new_tags(row[5], 'publisher').each do |publisher|
					game.tags.push(publisher) unless game.tags.include?(publisher)
				end
			end

			# add platforms
			if row[6]
				new_tags(row[6], 'platform').each do |platform|
					game.tags.push(platform) unless game.tags.include?(platform)
				end
			end

			# add description
			description = "[Suggest a description for this game.](/suggestions/#{game.slug})"
			game.description = row[7] if row[7] 
			game.description = description if row[7].nil? and (game.description.nil? or game.description.strip.empty?)

			# add thumbnail
			thumbnail_url = row[8]
			if not thumbnail_url.nil? and Rails.env == 'production'
				thumbnail = download thumbnail_url, "#{Dir.tmpdir}/#{game.slug}_thumbnail#{File.extname(thumbnail_url)}"
				game.thumbnail = File.new(thumbnail) unless thumbnail.nil?
			end

			# add background
			background_url = row[9]
			if not background_url.nil? and Rails.env == 'production'
				background = download background_url, "#{Dir.tmpdir}/#{game.slug}_background#{File.extname(background_url)}"
				game.background = File.new(background) unless background.nil?
			end

      # try to save
      begin
  			game.save!
      rescue Exception => e
        logger.error "Failed to save game #{game.title}: #{e.message}"
        logger.debug e.backtrace.inspect
      end
		end
  end

	def create_background_url(original_url, slug, ext)
		tmpfile = download original_url, "#{Dir.tmpdir}/#{slug}_background#{ext}"

		if tmpfile
			background tmpfile, "#{Rails.public_path}/images/#{slug}_background#{ext}"
			return "/images/#{slug}_background#{ext}"
		else
			return ''
		end
	end

	def create_thumbnail_url(original_url, slug, ext)
		tmpfile = download original_url, "#{Dir.tmpdir}/#{slug}_thumbnail#{ext}"

		if tmpfile
			thumbnail tmpfile, "#{Rails.public_path}/images/#{slug}_thumbnail#{ext}"
			return "/images/#{slug}_thumbnail#{ext}"
		else
			return ''
		end
	end

	def download full_url, to_here
		begin
			require 'open-uri'
			writeOut = open(to_here, "wb")
			writeOut.write(open(full_url).read)
			writeOut.close
			return to_here
		rescue
			puts "Unable to download file: #{full_url}"
			return nil
		end
	end

	def thumbnail file_path, target_path
		begin
			require 'RMagick'
			width, height = 160, 160
			img = Magick::Image.read(file_path).first
			thumb = img.resize_to_fill(width, height)
			thumb.write(target_path)
			target_path
		rescue
			#log
			puts "Error creating thumbnail of #{file_path}"
		ensure
			File.delete(file_path)
		end
	end

	def background file_path, target_path
		begin
			require 'RMagick'
			width, height = 800, 800
			img = Magick::Image.read(file_path).first
			back = img.sample(width, height)
			back.write(target_path)
			target_path
		rescue
			#log
			puts "Error creating background of #{file_path}"
		ensure
			File.delete(file_path)
		end
	end

	def new_tags(input, category)
		tags = input.split(';').map{|tag| tag.strip}

		tags.collect do |tag_name|
			Tag.find_by_name_and_category(tag_name, category) || Tag.create(:name => tag_name, :category => category, :description => '')
		end
	end
end
