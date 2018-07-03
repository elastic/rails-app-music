require 'test_helper'

class AlbumTest < ActiveSupport::TestCase

  test "Album #new" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)
    assert album.title == 'Like Water for Chocolate'
    assert album.artist == artist
  end

  test "Album #mappings" do
    expected_mappings = {:_doc =>
                             {:properties =>
                                  {:created_at => {:type => "date"},
                                   :updated_at => {:type => "date"},
                                   :artist=>{:type=>"text", :index=>false},
                                   :artist_id=>{:type=>"text", :index=>false},
                                   :label => {:type => "object"},
                                   :title => {:type => "text"},
                                   :tracklist => {:type => "text"},
                                   :released => {:type => "date"},
                                   :notes => {:type => "text"},
                                   :uri => {:type => "text"},
                                   :album_suggest => {:type => "object", :properties => {:title => {:type => "completion"}}}
                                  }
                             }
                          }

    assert expected_mappings[:_doc][:properties].keys.to_set ==
               Album.mappings.to_hash[:_doc][:properties].keys.to_set
    assert expected_mappings[:_doc][:properties].all? do |key|
      Album.mappings.to_hash[:_doc][:properties][key] == expected_mappings[:_doc][:properties][key]
    end
  end

  test "Album #to_hash" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)
    hash_representation = album.to_hash
    assert hash_representation[:join_field] == { 'name' => Album::JOIN_TYPE, 'parent' => 1 }
    assert hash_representation[:album_suggest][:title] == { input: ['Like Water for Chocolate'] }
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
end