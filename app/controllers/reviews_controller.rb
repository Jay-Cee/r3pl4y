class ReviewsController < ApplicationController
	before_filter :authenticate_user!, :except => [:show, :index]


  # GET /reviews
  # GET /reviews.json
  def index
		user_name = params["user_id"]
		rating = params[:rating]
		from = params['from'] ? DateTime.parse(params['from']) : DateTime.now()

		reviews = last_reviews(user_name, from, rating)

		respond_to do |format|
			format.text { render :partial => 'reviews/user_reviews.text.erb', :object => reviews }
		end
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    @review = Review.find(params[:id])

    respond_to do |format|
      if current_user
        format.html { render :layout => 'profile' }
        format.text { render :layout => false }
      else
        format.html # show.html.erb
        format.json { render json: @review }
        format.text { render :layout => false }
      end
    end
  end

  # GET /reviews/new
  # GET /reviews/new.json
  def new
    @review = Review.new
    @review.game = Game.find(params[:game_id])

    respond_to do |format|
      if current_user
        format.html { render :layout => false }
        format.json { render json: @review }
      end
    end
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = Review.new(params[:review])

	  @review.user_id = current_user.id
	  @review.published = Time.now.utc.round() # round to nearest second

    respond_to do |format|
      if @review.save
        format.html { redirect_to @review.game, notice: 'Review was successfully created.' }
        format.json { render json: @review, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @review = Review.find(params[:id])

    respond_to do |format|
      if current_user.id = @review.user_id or current_user.role == 'admin'
        format.html { render action: "new", :layout => false } # edit.html.erb
      else
        raise "Unauthorized to edit other users reviews"
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @review = Review.find(params[:id])

    respond_to do |format|
      if @review.update_attributes(params[:review])
        format.html { redirect_to @review, notice: 'Game was successfully updated.' }
        format.json { render :json => @review, :status => :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review = Review.find(params[:id])

		if current_user.id = @review.user_id or current_user.role == 'admin'
	    @review.destroy
		else
			raise "Unauthorized to delete other users reviews"
		end

    respond_to do |format|
      format.html { redirect_to profile_url }
      format.json { render :json => @review.id, :status => :ok } 
    end
  end


  private

  
    def last_reviews(user_name, from, rating)
        sql = "users.name = :name AND published <= :from"
        data = { :name => user_name, :from => from }

        # filter on rating
        if rating
            sql += " AND rating = :rating"
            data[:rating] = rating
        end

        Review.joins(:user).where(sql, data).order('published DESC').limit(11)	
    end
end
