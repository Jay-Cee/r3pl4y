# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def CreateTags(names, category)
    tags = names.map {|name| { name: name, description: '', category: category} }
    Tag.create(tags)
end

# create platforms
platforms = CreateTags ["3DO", "Amiga", "Amiga CD32", "Amiga CDTV", "Amstrad", "Android", "Apple II", "Apple IIGS", "Arcade", "Atari", "Atari ST", "BBC Micro", "Blackberry", "Browser", "Commodore 128", "Commodore 64", "Commodore VIC-20", "DOS", "Dreamcast", "Game Boy", "GameCube", "Game Gear", "iOS", "Jaguar", "Linux", "Mac", "Macintosh", "Mac OS X", "NES", "Nintendo 64", "Nintendo DS", "PC", "Playstation", "PS2", "PS3", "PSP", "Saturn", "Sega Master System", "Sega Mega Drive", "Super NES", "Wii", "Windows", "XBox", "XBox 360", "ZX Spectrum"], 'platform'

platforms.each {|platform| puts "Created platform: #{platform.name}" }

# create genres
genres = CreateTags ["Action", "Adventure", "Arcade", "Beat-Em-Up", "Board", "Data-Disk", "Educational", "Flight", "FPS", "Hack-And-Slash", "Horror", "Indie", "Miscellaneous", "MMORPG", "Music", "Platform", "Puzzle", "Racing", "Role-Playing", "RTS", "Shoot-Em-Up", "Simulation", "Sports", "Strategy", "Unreleased"], "genre"

genres.each {|genre| puts "Created genre: #{genre.name}" }

# create developers
developers = CreateTags ["Artdink"], "studio"

developers.each {|developer| puts "Created sample developer: #{developer.name}" }

# create publishers
publishers = CreateTags ["Ocean Software", "Maxis"], "publisher"

publishers.each {|publisher| puts "Created sample publishers: #{publisher.name}" }

# create root user
user = User.create :name => "rubriks", :role => "admin", :email => "info@rubriks.se", :password => "abc123", :picture => 'https://twimg0-a.akamaihd.net/profile_images/2222975432/missing.png'

puts "Created root user: #{user.name}"

# create a sample game
selected_genres = genres.find_all {|genre| genre == "Simulation"}
selected_platforms = platforms.find_all {|platform| platform == "Amiga" or platform == "PC" or platform == "Macintosh" or platform == "Sega Mega Drive" or platform == "Playstation" or platform == "NES" or platform == "PS2" or platform == "Nintendo DS"}

game = Game.create :title => "A-train", :slug => "a-train", :description => "The game places players in command of a railway company. There are no rival companies; the player controls the only one in the city and the game is resultingly fairly open-ended. A-Train is the first game in the series to use of near-isometric dimetric projection to present the city, similar to Maxis's SimCity 2000. There are two types of transport that the player's company can take: passengers or building materials. The former is more likely to be profitable, but building materials allow the city to grow.", :released => Date.parse("1992-01-01"), :is_public => true, :thumbnail_file_name => "http://files.r3pl4y.com/thumbnails/8/medium.jpg", :thumbnail_content_type => "image/jpeg", :thumbnail_file_size => 9449, :background_file_name => "http://files.r3pl4y.com/backgrounds/8/full.png", :background_content_type => "image/png", :background_file_size => 733481, :tags => (selected_genres + selected_platforms + developers + publishers)

puts "Created sample game: #{game.title}"

# create sample review
review = Review.create :rating => 2, :review => "I loved Sid Meier's Railroads Tychoon. It was one of my top 5 games. Building railroads and watching those trains come and go, making sure they travel with the right cargo, maximizing the profit.\n\nSo, I did wish me A-Train for christmas and I got it. I seldom got any games that I wished for but for once I did. I booted it up and it had this great into, and then extraordinary graphics. You could see every building in detail and it actually had daytime and nighttime. And don't start with the music, the music was fantastic!\n\nNow, here comes the catch. I couldn't figure it out. I spent hours upon hours and I couldn't get my railway company to turn a profit. I just built up more and more dept until I was bankrupt.\n\nI tried everything. I built these very modest railways that should be as cost effective as possible, but I could only barely make it break even, which gave me no room for expansion.\n\nDisappointment.", :finished => true, :published => Date.parse("2012-05-12T17:37:38Z"), :game_id => game.id, :user_id => user.id

puts "\nDone."
puts "Create new users with following invite url:\nhttp://localhost:3000/users/#{user.name}/invite/#{user.invite_phrase}"
