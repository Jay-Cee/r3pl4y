# Recreate search index for game_ids
#
# Open up console and queue the job like this
# Game.find_in_batches do |games|
#   game_ids = games.map {|game| game.id}
#   Delayed::Job.enqueue(RecreateSearchIndexJob.new(game_ids))
# end
#
# This will enqueue about 20 batches of 1000 games in each
# with a total size of 20000 games in database
class RecreateSearchIndexJob < Struct.new(:game_ids)
  def perform
    logger = Rails.logger
    logger.info "START: Recreate search index job"

    Game.find_all_by_id(game_ids).each do |game|
      begin
        
        logger.debug "SearchIndexObserver: Create words for #{game.title}"

        # clear words for game
        GameWord.destroy_all(:game_id => game.id)

        # slugify the title
        slug = Game.create_slug(game.title)

        # get all words > 2 in length
        words = slug.split('-').find_all {|item| item.length > 2}

        words.each do |word|
          index = Word.find_by_word(word)

          if index
            game.words.push(index)
          else
            game.words.push(Word.create! :word => word)
          end
        end

        game.save
      rescue Exception => e
        logger.error "Failed to create indexes for game #{game.title}: #{e.message}"
      end
    end

    logger.info "DONE: Recreate search index job"
  end
end
