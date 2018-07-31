require 'test_helper'

class AlbumTest < ActiveSupport::TestCase

  setup do
    Album.create_index!(force: true)
  end

  test "Album #new" do
    artist = Artist.create(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)
    assert album.title == 'Like Water for Chocolate'
    assert album.artist == artist
  end

  test "Album #mappings" do
    expected_mappings = {:_doc=>
                             {:properties=>
                                  {:created_at=>{:type=>"date"},
                                   :updated_at=>{:type=>"date"},
                                   :artist=>{:type=>"text"},
                                   :artist_id=>{:type=>"keyword"},
                                   :title=>{:type=>"keyword"},
                                   :released=>{:type=>"date"},
                                   :suggest=>{:type=>"object", :properties=>{
                                       :album_title=>{:type=>"completion"},
                                       :artist_name=>{:type=>"completion"}}}}}}

    assert expected_mappings[:_doc][:properties].keys.to_set ==
               Album.mappings.to_hash[:_doc][:properties].keys.to_set
    assert expected_mappings[:_doc][:properties].all? do |key|
      Album.mappings.to_hash[:_doc][:properties][key] == expected_mappings[:_doc][:properties][key]
    end
  end

  test "Album #to_hash" do
    artist = Artist.create(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)
    hash_representation = album.to_hash
    assert hash_representation[:suggest][:album_title] == { input: ['Like Water for Chocolate'] }
    assert hash_representation[:suggest][:artist_name] == { input: ['Common', '1'] }
  end

  test "Album validation with no title" do
    album = Album.new
    assert_not album.save
  end

  test "Album validation with no artist" do
    album = Album.new(title: 'Like Water for Chocolate')
    assert_not album.save
  end

  test "Album validation with unpersisted artist" do
    album = Album.new(title: 'Like Water for Chocolate', artist: Artist.new)
    assert_not album.save
  end

  test "Album validation with persisted artist" do
    artist = Artist.create(id: 1, name: 'Common')
    album = Album.create(title: 'Like Water for Chocolate', artist: artist)

    assert album.artist == artist
    assert Album.find(album.id).artist.name == artist.name
  end

  test "Album#artist_name" do
    artist = Artist.create(id: 1, name: 'Common')
    album = Album.create(title: 'Like Water for Chocolate', artist: artist)

    assert album.artist_name == artist.name
  end
end