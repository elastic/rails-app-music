require 'test_helper'

class SuggesterTest < ActiveSupport::TestCase

  setup do
    @album_repository = AlbumRepository.new(client: DEFAULT_CLIENT)
    @artist_repository = ArtistRepository.new(client: DEFAULT_CLIENT)
    @artist_repository.create_index!(force: true)
    @album_repository.create_index!(force: true)

    @artist = Artist.new(name: 'Common', members: ['Nick', 'Larry'])
    @artist.id = @artist_repository.save(@artist, refresh: true)['_id']
    @album = Album.new({ title: 'Like Water for Chocolate', artist: @artist })
    @album.id = @album_repository.save(@album, refresh: true)['_id']
  end

  teardown do
    begin
      @artist_repository.delete_index!
      @album_repository.delete_index!
    rescue
    end
  end

  test "Suggester with results by Artist name" do
    suggester = Suggester.new(term: 'co')
    suggester.execute!(@artist_repository, @album_repository)
    bands = suggester.as_json(@artist_repository).find { |hash| hash[:label] == "Matches" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Common"
  end

  test "Suggester with results by Album title" do
    suggester = Suggester.new(term: 'Lik')
    suggester.execute!(@artist_repository, @album_repository)
    bands = suggester.as_json.find { |hash| hash[:label] == "Matches" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Like Water for Chocolate"
  end

  test "Suggester with results by Member name" do
    suggester = Suggester.new(term: 'Nic')
    suggester.execute!(@artist_repository, @album_repository)
    bands = suggester.as_json.find { |hash| hash[:label] == "Matches" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Nick"
  end

  test 'Suggester with results for both artist and album' do
    @album = Album.new({ title: 'Coorporate', artist: @artist })
    @album.id = @album_repository.save(@album, refresh: true)['_id']

    suggester = Suggester.new(term: 'Co')
    suggester.execute!(@artist_repository, @album_repository)
    bands = suggester.as_json.select { |hash| hash[:label] == "Matches" }
    assert bands.size == 2
    assert bands[0][:value][0][:url] == "artists/#{@artist.id}"
    assert bands[1][:value][0][:url] == "artists/#{@artist.id}"
    assert bands[0][:value][0][:text] == "Common"
    assert bands[1][:value][0][:text] == "Coorporate"
  end
end