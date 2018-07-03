require 'test_helper'

class ArtistTest < ActiveSupport::TestCase

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
                                   :date=>{:type=>"date"},
                                   :members=>{:type=>"text", :fields=>{:name=>{:type=>"text", :analyzer=>"snowball"}, :raw=>{:type=>"keyword"}}},
                                   :members_combined=>{:type=>"text", :analyzer=>"snowball"},
                                   :urls=>{:type=>"text"},
                                   :artist_suggest=>
                                       {:type=>"object",
                                        :properties=>
                                            {:name=>{:type=>"object", :properties=>{:input=>{:type=>"completion"}, :output=>{:type=>"keyword", :index=>false}, :payload=>{:type=>"object", :enabled=>false}}},
                                             :member=>{:type=>"object", :properties=>{:input=>{:type=>"completion"}, :output=>{:type=>"keyword", :index=>false}, :payload=>{:type=>"object", :enabled=>false}}}}}}}}

    assert expected_mappings[:_doc][:properties].keys.to_set ==
               Artist.mappings.to_hash[:_doc][:properties].keys.to_set
    assert expected_mappings[:_doc][:properties].all? do |key|
      Artist.mappings.to_hash[:_doc][:properties][key] == expected_mappings[:_doc][:properties][key]
    end
  end

  test "Artist #to_hash" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['dave', 'diana'])
    hash_representation = artist.to_hash
    assert hash_representation[:join_field] == Artist::JOIN_TYPE
    assert hash_representation[:artist_suggest][:members] == { input: ['dave', 'diana'] }
    assert hash_representation[:artist_suggest][:name] == { input: [ 'Common' ]}
  end

  test "Artist validation" do
    artist = Artist.new(profile: 'etc etc', members: ['dave', 'diana'])
    assert_not artist.save
  end
end