# Reprocess thumbnails for game_ids
# Takes an array of ids, because you don't want to hook the
# delayed job worker process for 20000+ reprocessing runs. It
# will take too long, and put off more important things.
#
# Open up console and queue the job like this
# Game.find_in_batches(:conditions => "thumbnail_file_name IS NOT NULL", :batch_size => 250) do |games|
#   game_ids = games.map {|game| game.id}
#   Delayed::Job.enqueue(ReprocessThumbnailsJob.new(game_ids))
# end
#
# This will enqueue about 80 batches of 250 games in each
# with a total size of 20000 games in database
class ReprocessThumbnailsJob < Struct.new(:game_ids)
  def perform
    logger = Rails.logger
    logger.info "START: Reprocess Thumbnails Job"

    Game.find_all_by_id(game_ids).each do |game|
      begin
        logger.debug "Reprocess game #{game.title}"
        game.thumbnail.reprocess!
      rescue Exception => e
        logger.error "Failed to reprocess game #{game.title}: #{e.message}"
      end
    end

    logger.info "DONE: Reprocess Thumbnails Job"
  end
end
