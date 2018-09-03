require 'test_helper'

class AlbumRepositoryTest < ActiveSupport::TestCase

  setup do
    @repository = AlbumRepository.new(client: DEFAULT_CLIENT)
    @repository.create_index!(force: true)
  end

  test "AlbumRepository #save" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)
    assert @repository.save(album)['_id']
  end

  test "Album #mappings" do
    expected_mappings = {:_doc=>
                             {:properties=> {
                                   :label=>{:type=>"object"},
                                   :title=>{:type=>"text"},
                                   :notes=>{:type=>"text"},
                                   :tracklist_combined=>{:type=>"text"},
                                   :album_suggest=>{:type=>"object", :properties=>{
                                       :title=>{:type=>"completion"},
                                       :tracklist=>{:type=>"completion"}}}}}}

    assert expected_mappings[:_doc][:properties].keys.to_set ==
               @repository.mappings.to_hash[:_doc][:properties].keys.to_set
    assert expected_mappings[:_doc][:properties].all? do |key|
      @repository.mappings.to_hash[:_doc][:properties][key] == expected_mappings[:_doc][:properties][key]
    end
  end

  test "AlbumRepository #find" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)
    album.id = @repository.save(album, refresh: true)['_id']
    persisted_album = @repository.find(album.id)
    assert HashWithIndifferentAccess.new(persisted_album.attributes) ==
               HashWithIndifferentAccess.new(album.attributes)
  end

  test "Album validation with no title" do
    album = Album.new
    assert_raises(ActiveModel::ValidationError) { @repository.save(album) }
  end

  test "Album validation with no artist" do
    album = Album.new(title: 'Like Water for Chocolate')
    assert_raises(ActiveModel::ValidationError) { @repository.save(album) }
  end

  test "Album validation with unpersisted artist" do
    album = Album.new(title: 'Like Water for Chocolate', artist: Artist.new)
    assert_raises(ActiveModel::ValidationError) { @repository.save(album) }
  end

  test "Album validation with persisted artist" do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate', artist: artist)

    assert album.artist == artist
    assert @repository.save(album)
    assert @repository.find(@repository.save(album)['_id']).is_a?(Album)
  end

  test 'AlbumRepository #serialize' do
    artist = Artist.new(id: 1, name: 'Common')
    album = Album.new(title: 'Like Water for Chocolate',
                      artist: artist,
                      tracklist: [' The Light ', ' The Questions '],
                      label: 'MCA')
    doc = @repository.serialize(album)
    assert doc[:artist].nil?
    assert doc[:artist_id] == 1
    assert doc[:tracklist] == [' The Light ' , ' The Questions ']
    assert doc[:album_suggest][:title] == { input: ['Like Water for Chocolate'] }
    assert doc[:album_suggest][:tracklist] == { input: ['The Light', 'The Questions'] }
  end
end