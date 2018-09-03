require 'test_helper'

class AlbumTest < ActiveSupport::TestCase

  test "Album #new" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)
    assert album.title == 'Like Water for Chocolate'
    assert album.artist == artist
  end

  test "Album #attributes" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate',
                      artist: artist,
                      tracklist: ['The Light', 'The Questions'],
                      label: 'MCA')
    assert album.attributes[:title] == 'Like Water for Chocolate'
    assert album.attributes[:tracklist] == ['The Light', 'The Questions']
    assert album.attributes[:label] == 'MCA'
  end

  test "Album #to_hash" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate',
                      artist: artist,
                      tracklist: [' The Light ', ' The Questions '],
                      label: 'MCA')
    assert album.to_hash == album.attributes
  end

  test "Album validation with no title" do
    album = Album.new
    assert_not album.valid?
  end

  test "Album validation with no artist" do
    album = Album.new(title: 'Like Water for Chocolate')
    assert_not album.valid?
  end

  test "Album validation with unpersisted artist" do
    album = Album.new(title: 'Like Water for Chocolate', artist: Artist.new)
    assert_not album.valid?
  end

  test "Album validation with persisted artist" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)

    assert album.artist == artist
    assert album.valid?
  end
end