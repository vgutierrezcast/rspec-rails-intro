require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    let(:fake_results) do
      [
        Movie.new(title: 'Movie One', rating: 'R'),
        Movie.new(title: 'Movie Two', rating: 'R')
      ]
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb)
        .with('hardware')
        .and_return(fake_results)

      get :search_tmdb, params: { search_terms: 'hardware' }
    end

    describe 'after a valid search' do
      before do
        allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
        get :search_tmdb, params: { search_terms: 'hardware' }
      end

      it 'renders the search results template' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the search results available to the template' do
        expect(assigns(:movies)).to eq(fake_results)
      end
    end

    it 'shows a warning when the title is missing' do
      get :search_tmdb, params: { search_terms: '' }

      expect(flash[:warning]).to eq('Please fill in all required fields!')
    end

    it 'shows a warning when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])

      get :search_tmdb, params: { search_terms: 'no-such-movie' }

      expect(flash[:warning]).to eq('No movies found with given parameters!')
    end
  end

  describe 'adding a movie' do
    it 'saves the submitted movie and redirects' do
      expect {
        post :add_movie, params: {
          title: 'Test Movie',
          release_date: '2020-01-01',
          rating: 'R',
          description: 'A test movie'
        }
      }.to change(Movie, :count).by(1)

      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:notice]).to include('Test Movie')
    end
  end
end
