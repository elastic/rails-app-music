require 'test_helper'

class SuggesterTest < ActiveSupport::TestCase

  setup do
    begin; Artist.gateway.delete_index!; rescue; end
    Artist.create_index!
    @artist = Artist.create(name: 'Common', members: ['Nick', 'Larry'], refresh: true)
    @album = Album.create({ title: 'Like Water for Chocolate', artist: @artist }, refresh: true)
  end

  teardown do
    begin; Artist.gateway.delete_index!; rescue; end
  end

  test "Suggester with results by Artist name" do
    suggester = Suggester.new(term: 'co')
    bands = suggester.as_json.find { |hash| hash[:label] == "Bands" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Common"
  end

  test "Suggester with results by Members" do
    suggester = Suggester.new(term: 'Nic')
    bands = suggester.as_json.find { |hash| hash[:label] == "Band Members" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Nick"
  end

  test "Suggester with results by Album title" do
    suggester = Suggester.new(term: 'Lik')
    bands = suggester.as_json.find { |hash| hash[:label] == "Albums" }[:value]
    assert bands.size == 1
    assert bands[0][:url] == "artists/#{@artist.id}"
    assert bands[0][:text] == "Like Water for Chocolate"
  end
end