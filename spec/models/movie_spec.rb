require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Movie, type: :model do
  describe '.find_in_tmdb' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('TMDB_API_KEY').and_return('test-api-key')
    end

    it 'returns movie objects from the TMDb response without saving them' do
      stub_request(:get, %r{api\.themoviedb\.org/3/search/movie})
        .to_return(
          status: 200,
          body: {
            results: [
              {
                title: 'Test Movie',
                release_date: '2020-01-01',
                overview: 'A test description'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      movies = Movie.find_in_tmdb('Test Movie')

      expect(movies.length).to eq(1)
      expect(movies.first.title).to eq('Test Movie')
      expect(movies.first.description).to eq('A test description')
      expect(movies.first).to be_new_record
    end

    it 'returns an empty array when TMDb has no results' do
      stub_request(:get, %r{api\.themoviedb\.org/3/search/movie})
        .to_return(
          status: 200,
          body: { results: [] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect(Movie.find_in_tmdb('No Such Movie')).to eq([])
    end
  end
end
