class SuggestionsController < ApplicationController
  before_filter :authenticate_user!, :except => ["rss"]
  before_filter :authenticate_admin!, :except => ["show", "create", "rss"]

  # GET /suggestions
  # GET /suggestions.json
  def index
    @suggestions = Suggestion.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @suggestions }
    end
  end

  def rss
    @suggestions = Suggestion.order("created_at DESC").limit(10)

    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  # GET /suggestions/1
  # GET /suggestions/1.json
  def show
    @suggestion = Suggestion.new
    @suggestion.game = Game.find_by_slug(params[:id])
    @suggestion.user = current_user

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @suggestion }
    end
  end

  def preview
    suggestion = Suggestion.find(params[:id])
    @game = Game.find(suggestion.game_id)
    @game.description = suggestion.description
    @reviews = []
    render 'games/show'
  end

  def accept
    suggestion = Suggestion.find(params[:id])
    game = Game.find(suggestion.game_id)
    
    suggestion.accepted = true
    game.description = suggestion.description

    suggestion.save
    game.save

    redirect_to :action => "index", :notice => "Accepted description for #{game.title} from #{suggestion.user.name}"
  end

  def deny
    suggestion = Suggestion.find(params[:id])
    game = Game.find(suggestion.game_id)
    
    suggestion.accepted = false
    game.description = "[Suggest a description for this game.](/suggestion/#{game.slug})"

    suggestion.save
    game.save

    redirect_to :action => "index", :notice => "Denied description for #{game.title} from #{suggestion.user.name}"
  end

  # GET /suggestions/1/edit
  def edit
    @suggestion = Suggestion.find(params[:id])
  end

  # POST /suggestions
  # POST /suggestions.json
  def create
    @suggestion = Suggestion.new(params[:suggestion])
    @suggestion.user = current_user

    respond_to do |format|
      if @suggestion.save
        format.html { redirect_to :controller => 'profile', :action => 'index', notice: 'Suggestion was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /suggestions/1
  # PUT /suggestions/1.json
  def update
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      if @suggestion.update_attributes(params[:suggestion])
        format.html { redirect_to @suggestion, notice: 'Suggestion was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end
end
