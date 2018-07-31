require 'test_helper'
require 'pry-nav'

class SuggesterTest < ActiveSupport::TestCase

  setup do
    Artist.create_index!(force: true)
    Album.create_index!(force: true)
    @artist = Artist.create(name: 'Common', members: ['Nick', 'Larry'], refresh: true)
    @album = Album.create({ title: 'Like Water for Chocolate', artist: @artist }, refresh: true)
  end

  teardown do
    begin
      Artist.gateway.delete_index!
      Album.gateway.delete_index!
    rescue
    end
  end

  test "Suggester with results by Artist name" do
    suggester = Suggester.new(term: 'co')
    bands = suggester.as_json.find { |hash| hash[:label] == "Bands" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Common"
  end

  test "Suggester with results by Album title" do
    suggester = Suggester.new(term: 'Lik')
    bands = suggester.as_json.find { |hash| hash[:label] == "Albums" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Like Water for Chocolate"
  end

  test "Suggester with results by Member name" do
    suggester = Suggester.new(term: 'Nic')
    bands = suggester.as_json.find { |hash| hash[:label] == "Bands" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Common"
  end
end