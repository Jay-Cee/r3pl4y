# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130106133029) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.string   "twitter_uid"
    t.string   "facebook_uid"
    t.string   "steam_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "r3pl4y_uid"
  end

  add_index "friends", ["user_id"], :name => "index_friends_on_user_id"

  create_table "game_tags", :force => true do |t|
    t.integer  "game_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "game_tags", ["game_id"], :name => "index_game_tags_on_game_id"
  add_index "game_tags", ["tag_id"], :name => "index_game_tags_on_tag_id"

  create_table "game_words", :force => true do |t|
    t.integer "game_id"
    t.integer "word_id"
  end

  create_table "games", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.datetime "released"
    t.float    "rate_average",            :default => 0.0,   :null => false
    t.integer  "rate_quantity",           :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",               :default => false
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.integer  "background_file_size"
    t.datetime "background_updated_at"
  end

  add_index "games", ["slug"], :name => "unique_slug", :unique => true

  create_table "invites", :force => true do |t|
    t.string   "email"
    t.string   "hash"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "rating"
    t.text     "review"
    t.boolean  "finished"
    t.datetime "published"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    :null => false
  end

  create_table "suggestions", :force => true do |t|
    t.text     "description",                    :null => false
    t.boolean  "accepted",    :default => false, :null => false
    t.integer  "game_id",                        :null => false
    t.integer  "user_id",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suggestions", ["game_id"], :name => "index_suggestions_on_game_id"
  add_index "suggestions", ["user_id"], :name => "index_suggestions_on_user_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                         :default => ""
    t.string   "encrypted_password",            :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name",                          :default => "",       :null => false
    t.string   "role",                          :default => "member", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter_auth"
    t.string   "facebook_auth"
    t.string   "steam_auth"
    t.string   "real_name"
    t.string   "picture"
    t.integer  "invited_by"
    t.string   "twitter_oauth_token"
    t.string   "twitter_oauth_secret"
    t.string   "facebook_access_token"
    t.datetime "facebook_access_token_expires"
    t.integer  "score",                         :default => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "words", :force => true do |t|
    t.string   "word",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "words", ["word"], :name => "index_words_on_word"

  add_foreign_key "friends", "users", :name => "friends_user_id_fk", :dependent => :delete

  add_foreign_key "game_tags", "games", :name => "game_tags_game_id_fk", :dependent => :delete
  add_foreign_key "game_tags", "tags", :name => "game_tags_tag_id_fk", :dependent => :delete

  add_foreign_key "game_words", "games", :name => "game_words_game_id_fk", :dependent => :delete
  add_foreign_key "game_words", "words", :name => "game_words_word_id_fk", :dependent => :delete

  add_foreign_key "reviews", "games", :name => "reviews_game_id_fk"
  add_foreign_key "reviews", "users", :name => "reviews_user_id_fk"

  add_foreign_key "suggestions", "games", :name => "suggestions_game_id_fk", :dependent => :delete
  add_foreign_key "suggestions", "users", :name => "suggestions_user_id_fk"

end
