require 'test_helper'

class ArtistRepositoryTest < ActiveSupport::TestCase

  setup do
    @repository = ArtistRepository.new(client: DEFAULT_CLIENT)
    @repository.create_index!(force: true)
  end

  test "ArtistRepository #save" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['Jack', 'Larry'])
    assert @repository.save(artist)['_id']
  end

  test "ArtistRepository #mappings" do
    expected_mappings = {:_doc=>
                             {:properties=>
                                  {:members_combined=>{:analyzer=>"snowball", :type=>"text"},
                                   :name=>{:type=>"text", :fields=>{:name=>{:type=>"text", :analyzer=>"snowball"}, :raw=>{:type=>"keyword"}}},
                                   :profile=>{:type=>"text"},
                                   :members=>{:type=>"text", :fields=>{:name=>{:type=>"text", :analyzer=>"snowball"}, :raw=>{:type=>"keyword"}}},
                                   :artist_suggest=>{:type=>"object", :properties=>{:name=>{:type=>"completion"}, :members=>{:type=>"completion"}}}}}}

    assert expected_mappings[:_doc][:properties].keys.to_set ==
               @repository.mappings.to_hash[:_doc][:properties].keys.to_set
    assert expected_mappings[:_doc][:properties].all? do |key|
      @repository.mappings.to_hash[:_doc][:properties][key] == expected_mappings[:_doc][:properties][key]
    end
  end

  test "ArtistRepository #find" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['Jack', 'Larry'])
    artist.id = @repository.save(artist)['_id']
    persisted_artist = @repository.find(artist.id)
    assert HashWithIndifferentAccess.new(persisted_artist.attributes) ==
             HashWithIndifferentAccess.new(artist.attributes)
  end

  test "ArtistRepository #all" do
    artist_one = Artist.new(name: 'Common', profile: 'etc etc', members: ['Jack', 'Larry'])
    artist_two = Artist.new(name: 'FKA Twigs', profile: 'british', members: ['Tahliah'])
    @repository.save(artist_one, refresh: true)
    @repository.save(artist_two, refresh: true)
    assert @repository.all.collect(&:name) == ['Common', 'FKA Twigs']
  end
end