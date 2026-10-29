class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings
  
    raw_ratings = params[:ratings]
  
    raw_ratings = raw_ratings.keys if raw_ratings.is_a?(ActionController::Parameters) ||
                                      raw_ratings.is_a?(Hash)
  
    if raw_ratings.present?
      @ratings_to_show = Array(raw_ratings).reject(&:blank?)
      session[:ratings] = @ratings_to_show
    else
      @ratings_to_show = session[:ratings] || @all_ratings
    end
  
    sort_param = params[:sort_by].presence_in(%w[title release_date])
  
    if sort_param
      @sort_by = sort_param
      session[:sort_by] = @sort_by
    else
      @sort_by = session[:sort_by] || "title"
    end
  
    @movies = Movie.with_ratings(@ratings_to_show, @sort_by)
  end
  

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  # GET /search
  def search_tmdb
    @title = params[:search_terms].presence || params[:title]
    @release_year = params[:release_year]
    @language = params[:language]

    if @title.blank?
      @movies = []
      flash.now[:warning] = "Please fill in all required fields!"
      return
    end

    if @release_year.present? || @language.present?
      @movies = Movie.find_in_tmdb(@title, @release_year, @language)
    else
      @movies = Movie.find_in_tmdb(@title)
    end

    flash.now[:warning] = "No movies found with given parameters!" if @movies.empty?
  end

  # POST /add_movie
  def add_movie
    movie = Movie.new(
      title: params[:title],
      release_date: params[:release_date].presence,
      rating: params[:rating].presence || 'R',
      description: params[:description]
    )

    if movie.save
      redirect_to search_tmdb_path,
                  notice: "#{movie.title} was successfully added to RottenPotatoes."
    else
      redirect_to search_tmdb_path,
                  alert: "Could not add the movie."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end