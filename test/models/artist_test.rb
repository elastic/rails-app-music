require 'test_helper'

class ArtistTest < ActiveSupport::TestCase

  setup do
    Artist.create_index!(force: true)
  end

  test "Artist #new" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['dave', 'diana'])
    assert artist.name == 'Common'
    assert artist.profile == 'etc etc'
    assert artist.members == ['dave', 'diana']
  end

  test "Artist #mappings" do
    expected_mappings = {:_doc=>
                             {:properties=>
                                  {:created_at=>{:type=>"date"},
                                   :updated_at=>{:type=>"date"},
                                   :name=>{:type=>"text", :fields=>{:name=>{:type=>"text", :analyzer=>"snowball"}, :raw=>{:type=>"keyword"}}},
                                   :profile=>{:type=>"text"},
                                   :members=>{:type=>"text", :fields=>{:name=>{:type=>"text", :analyzer=>"snowball"}, :raw=>{:type=>"keyword"}}},
                                   :artist_suggest=>{:type=>"object", :properties=>{:name=>{:type=>"completion"}, :members=>{:type=>"completion"}}}}}}

    assert expected_mappings[:_doc][:properties].keys.to_set ==
               Artist.mappings.to_hash[:_doc][:properties].keys.to_set
    assert expected_mappings[:_doc][:properties].all? do |key|
      Artist.mappings.to_hash[:_doc][:properties][key] == expected_mappings[:_doc][:properties][key]
    end
  end

  test "Artist #to_hash" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['dave', 'diana'])
    hash_representation = artist.to_hash
    assert hash_representation[:artist_suggest][:members] == { input: ['dave', 'diana'] }
    assert hash_representation[:artist_suggest][:name] == { input: [ 'Common' ]}
  end

  test "Artist#all" do
    Artist.create({ name: 'Common' }, refresh: true)
    Artist.create({ name: 'Common' }, refresh: true)
    assert Artist.all.collect(&:name) == ['Common', 'Common']
  end

  test "Artist validation" do
    artist = Artist.new(profile: 'etc etc', members: ['dave', 'diana'])
    assert_not artist.save
  end

  test "Artist#albums" do
    artist = Artist.create(name: 'Common', profile: 'etc etc', members: ['dave', 'diana'])
    Album.create({ title: 'Like Water for Chocolate', artist: artist }, refresh: true)
    assert artist.albums.first.title == 'Like Water for Chocolate'
  end
end