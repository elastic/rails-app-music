require 'test_helper'

class ArtistTest < ActiveSupport::TestCase

  test "Artist #new" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['Jack', 'Larry'])
    assert artist.name == 'Common'
    assert artist.profile == 'etc etc'
    assert artist.members == ['Jack', 'Larry']
  end

  test "Artist #attributes" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['Jack', 'Larry'])
    assert artist.attributes[:name] == 'Common'
    assert artist.attributes[:profile] == 'etc etc'
    assert artist.attributes[:members] == ['Jack', 'Larry']
  end

  test "Artist mutability" do
    artist = Artist.new(name: 'Common', profile: 'etc etc')
    artist.name = 'FKA Twigs'
    assert artist.name == 'FKA Twigs'
    assert artist.profile == 'etc etc'
  end

  test "Artist #to_hash" do
    artist = Artist.new(name: 'Common', profile: 'etc etc', members: ['Jack', 'Larry'])
    hash = artist.to_hash
    assert hash[:name] == 'Common'
    assert hash[:profile] == 'etc etc'
    assert hash[:members] == ['Jack', 'Larry']
  end

  test "Artist validation" do
    artist = Artist.new(profile: 'etc etc', members: ['Jack', 'Larry'])
    assert_not artist.valid?
  end
end
