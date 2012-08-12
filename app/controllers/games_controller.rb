class GamesController < ApplicationController

	before_filter :authenticate_user!
  before_filter :authenticate_admin!, :except => ['show', 'reviews', 'rss']

  # GET /games
  # GET /games.json
  def index
    @games = Game.order('title')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

	def oldest
		@games = Game.order('updated_at ASC').limit(50)

		respond_to do |format|
			format.html { render 'index' }
		end
	end



  # GET /games/bastion
  # GET /games/bastion.json
  def show
    @game = Game.where(:slug => params[:id]).first

    # 404
    return render(:text => 'Not found', :status => 404) if @game.nil?
    # 403
    return render(:text => 'Forbidden', :status => 403) if not @game.is_public and (current_user and current_user.role != 'admin')
    
		
		from = params['from'] ? DateTime.parse(params['from']) : DateTime.now()
		@reviews = reviews_for_game(@game.slug, from)

    respond_to do |format|
      if current_user
        format.html { render :layout => 'profile' }
        format.text { render :layout => false }
        format.rss { render :layout => false }
      else
        format.html # show.html.erb
        format.json { render json: @game }
        format.rss { render :layout => false }
        format.text { render :layout => false }
      end
    end
  end

	def reviews_for_game(slug, from)
		Review.joins(:game).where("games.slug = :slug AND published <= :from", { :slug => slug, :from => from }).order('published DESC').limit(11)
	end

	def reviews
		slug = params[:slug]
		from = params['from'] ? DateTime.parse(params['from']) : DateTime.now()

		@reviews = reviews_for_game(slug, from) 

		respond_to do |format|
			format.text { render :partial => 'reviews/game_reviews.text.erb', :object => @reviews }
		end
	end

	def duplicates
		@slug = params[:slug]
		words = @slug.split('-')

		sql = "SELECT * FROM games INNER JOIN ("
		sql += "SELECT gw.game_id"

		for i in 1..words.length do
			sql += ", max(w#{i}.id) as word#{i}"
		end

		sql += " FROM game_words gw "

		# join for every word
		for i in 1..words.length do
			sql += "LEFT JOIN words w#{i} ON w#{i}.id = gw.word_id AND w#{i}.word = ? "
		end

		sql += "WHERE "

		# filter those not matching
		for i in 1..words.length do
			sql += "w#{i}.word = ? "
			sql += "OR " unless i == words.length # last
		end

		sql += "GROUP BY gw.game_id ORDER BY "

		# fix ordering
		for i in 1..words.length do
			sql += "word#{i}"
			sql += ", " unless i == words.length # last
		end

		sql += " LIMIT 10) AS words ON id = words.game_id"
		sql += " WHERE slug != ?"
		query = [sql] + (words * 2) + [@slug]
		@duplicates = Game.find_by_sql query
	end

	def rss
		@game = Game.find_by_slug(params[:id])
  	@reviews = Review.find(:all, :order => "id DESC", :limit => 10)
  	render :layout => false
  	response.headers["Content-Type"] = "application/xml; charset=utf-8"
	end

	# GET /games/:id/merge/:with
	def merge
		@original = Game.find_by_slug(params[:slug])
		@copy = Game.find_by_slug(params[:with])

    ActiveRecord::Base.transaction do
      # move reviews
      ActiveRecord::Base.connection.execute "UPDATE reviews SET game_id = #{@original.id} WHERE game_id = #{@copy.id}"

      # move suggestions
      ActiveRecord::Base.connection.execute "UPDATE suggestions SET game_id = #{@original.id} WHERE game_id = #{@copy.id}"

      # remove GameWords
      ActiveRecord::Base.connection.execute "DELETE FROM game_words WHERE game_id = #{@copy.id}" 

      # join tags
      @original.tags = @original.tags | @copy.tags

      # save original
      @original.save

      # destroy the copy
      @copy.destroy
    end

    respond_to do |format|
      format.html { redirect_to profile_url }
      format.json { head :ok }
    end

	end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new

		@platforms_list = Tag.where("category = 'platform'").order('name').collect {|t| [t.name, t.id]}
		@platforms_selected = [] 

		@genres_list = Tag.where("category = 'genre'").order('name').collect {|t| [t.name, t.id]}
		@genres_selected = []

		@publishers_list = Tag.where("category = 'publisher'").order('name').collect {|t| [t.name, t.id]}
		@publishers_selected = [] 

		@developers_list = Tag.where("category = 'studio'").order('name').collect {|t| [t.name, t.id]}
		@developers_selected = []

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find_by_slug(params[:id])

		@game_tags = GameTag.where("game_id = ?", @game.id)
		@tags_list = []

		@game_tags.each do |tags|
			@tags_list << tags.tag_id
		end

		@platforms_list = Tag.where("category = 'platform'").order('name').collect {|t| [t.name, t.id]}
		@platforms_selected = GameTag.joins(:tag).where("game_id = :game_id AND tags.category = 'platform'", :game_id => @game.id).collect {|t| t.tag_id}

		@genres_list = Tag.where("category = 'genre'").order('name').collect {|t| [t.name, t.id]}
		@genres_selected = GameTag.joins(:tag).where("game_id = :game_id AND tags.category = 'genre'", :game_id => @game.id).collect {|t| t.tag_id}

		@publishers_list = Tag.where("category = 'publisher'").order('name').collect {|t| [t.name, t.id]}
		@publishers_selected = GameTag.joins(:tag).where("game_id = :game_id AND tags.category = 'publisher'", :game_id => @game.id).collect {|t| t.tag_id}

		@developers_list = Tag.where("category = 'studio'").order('name').collect {|t| [t.name, t.id]}
		@developers_selected = GameTag.joins(:tag).where("game_id = :game_id AND tags.category = 'studio'", :game_id => @game.id).collect {|t| t.tag_id}
  end

	def build_tags_from_params(params)
		tag_ids = []
		tag_ids |= params[:platforms] || []
		tag_ids |= params[:genres] || []
		tag_ids |= params[:publishers] || []
		tag_ids |= params[:developers] || []

		tags = Tag.find(tag_ids)

		# add any new platforms
		new_tags(params[:new_platforms], 'platform').each do |platform|
			tags.push(platform) unless @game.tags.include?(platform)
		end

		# add any new genres
		new_tags(params[:new_genres], 'genre').each do |genre|
			tags.push(genre) unless @game.tags.include?(genre)
		end

		# add any new publishers
		new_tags(params[:new_publishers], 'publisher').each do |publisher|
			tags.push(publisher) unless @game.tags.include?(publisher)
		end

		# add any new developers
		new_tags(params[:new_developers], 'studio').each do |developer|
			tags.push(developer) unless @game.tags.include?(developer)
		end

		return tags
	end

	def new_tags(input, category)
		tags = input.split(';').map{|tag| tag.strip}

		tags.collect do |tag_name|
			Tag.find_by_name_and_category(tag_name, category) || Tag.create(:name => tag_name, :category => category, :description => '')
		end
	end

  # POST /games
  # POST /games.json
  def create
    @game = Game.create(params[:game])
		@game.rate_average = 0.0
		@game.rate_quantity = 0	
		@game.tags = build_tags_from_params(params) if params[:commit] == 'Update Game' 

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find_by_slug(params[:id])
		@game.tags = build_tags_from_params(params) if params[:commit] == 'Update Game'

    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find_by_slug(params[:id])
    
    ActiveRecord::Base.transaction do
      @game.reviews.each {|review| review.destroy}

      # remove GameWords
      ActiveRecord::Base.connection.execute "DELETE FROM game_words WHERE game_id = #{@game.id}" 

      @game.destroy
    end

    respond_to do |format|
      format.html { redirect_to profile_url }
      format.json { head :ok }
    end
  end
end
