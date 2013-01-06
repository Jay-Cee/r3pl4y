class AddForeignKeys < ActiveRecord::Migration
  def up
    ### FRIENDS
    # clean up
    execute "DELETE FROM friends WHERE user_id IN (SELECT DISTINCT friends.user_id FROM friends LEFT OUTER JOIN users ON friends.user_id = users.id WHERE users.id IS NULL);"

    # add the foreign key
    change_table :friends do |t|
      t.foreign_key :users, dependent: :delete
    end

    ### Tags
    # clean up
    execute "DELETE FROM game_tags WHERE game_id IN (SELECT DISTINCT game_tags.game_id FROM game_tags LEFT OUTER JOIN games ON game_tags.game_id = games.id WHERE games.id IS NULL);"
    execute "DELETE FROM game_tags WHERE tag_id IN (SELECT DISTINCT game_tags.tag_id FROM game_tags LEFT OUTER JOIN tags ON game_tags.tag_id = tags.id WHERE tags.id IS NULL);"

    # add foreign key
    change_table :game_tags do |t|
      t.foreign_key :games, dependent: :delete
      t.foreign_key :tags, dependent: :delete
    end

    ### Words
    # clean up
    execute "DELETE FROM game_words WHERE game_id IN (SELECT DISTINCT game_words.game_id FROM game_words LEFT OUTER JOIN games ON game_words.game_id = games.id WHERE games.id IS NULL);"
    execute "DELETE FROM game_words WHERE word_id IN (SELECT DISTINCT game_words.word_id FROM game_words LEFT OUTER JOIN words ON game_words.word_id = words.id WHERE words.id IS NULL);"

    # add foreign key
    change_table :game_words do |t|
      t.foreign_key :games, dependent: :delete
      t.foreign_key :words, dependent: :delete
    end

    ### Reviews
    # clean up
    execute "DELETE FROM reviews WHERE game_id IN (SELECT DISTINCT reviews.game_id FROM reviews LEFT OUTER JOIN games ON reviews.game_id = games.id WHERE games.id IS NULL);"
    execute "DELETE FROM reviews WHERE user_id IN (SELECT DISTINCT reviews.user_id FROM reviews LEFT OUTER JOIN users ON reviews.user_id = users.id WHERE users.id IS NULL);"

    # add foreign key
    change_table :reviews do |t|
      t.foreign_key :games
      t.foreign_key :users
    end

    ### Suggestions
    # clean up
    execute "DELETE FROM suggestions WHERE game_id IN (SELECT DISTINCT suggestions.game_id FROM suggestions LEFT OUTER JOIN games ON suggestions.game_id = games.id WHERE games.id IS NULL);"
    execute "DELETE FROM suggestions WHERE user_id IN (SELECT DISTINCT suggestions.user_id FROM suggestions LEFT OUTER JOIN users ON suggestions.user_id = users.id WHERE users.id IS NULL);"

    # add foreign key
    change_table :suggestions do |t|
      t.foreign_key :games, dependent: :delete
      t.foreign_key :users
    end
  end

  def down
    change_table :friends do |t|
      t.remove_foreign_key :users
    end
    change_table :game_tags do |t|
      t.remove_foreign_key :games
      t.remove_foreign_key :tags
    end
    change_table :game_words do |t|
      t.remove_foreign_key :games
      t.remove_foreign_key :words
    end
    change_table :reviews do |t|
      t.remove_foreign_key :games
      t.remove_foreign_key :users
    end
    change_table :suggestions do |t|
      t.remove_foreign_key :games
      t.remove_foreign_key :users
    end
  end
end
