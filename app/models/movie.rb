class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end


  # Search TMDb and return unsaved Movie objects.
  def self.find_in_tmdb(title, release_year = nil, language = nil)
    require 'faraday'
    require 'json'

    api_key = ENV['TMDB_API_KEY']
    raise 'Set the TMDB_API_KEY environment variable before searching.' if api_key.blank?

    params = { api_key: api_key, query: title }
    params[:year] = release_year if release_year.present?
    params[:language] = 'en-US' if language == 'en'

    response = Faraday.get('https://api.themoviedb.org/3/search/movie', params)
    raise "TMDb request failed: HTTP #{response.status}" unless response.success?

    results = JSON.parse(response.body).fetch('results', [])
    results.map do |result|
      new(
        title: result['title'],
        release_date: result['release_date'].presence,
        rating: 'R',
        description: result['overview']
      )
    end
  end
end
