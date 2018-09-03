class ArtistRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name 'artists'
  klass Artist

  analyzed_and_raw = { fields: {
      name: { type: 'text', analyzer: 'snowball' },
      raw:  { type: 'keyword' }
  } }

  mapping do
    indexes :name, analyzed_and_raw
    indexes :members, analyzed_and_raw
    indexes :profile
    indexes :members_combined, { analyzer: 'snowball' }
    indexes :artist_suggest, {
        type: 'object',
        properties: {
            name: { type: 'completion' },
            members: { type: 'completion' }
        }
    }
  end

  def all(options = {})
    search({ query: { match_all: { } } },
           { sort: 'name.raw' }.merge(options))
  end

  def serialize(artist)
    artist.validate!
    artist.to_hash.tap do |hash|
      suggest = { name: { input: [ hash[:name] ] } }
      suggest[:members] = { input: hash[:members].collect(&:strip) } if hash[:members].present?
      hash.merge!(:artist_suggest => suggest)
    end
  end

  def artist_name(album)
    find(album.artist_id).name
  end

  def suggest_body(term)
    {
        suggest: {
            artist_names: {
                prefix: term,
                completion: { field: 'artist_suggest.name', size: 25 }
            },
            artist_members: {
                prefix: term,
                completion: { field: 'artist_suggest.members', size: 25 }
            }
        }
    }
  end

  def deserialize(document)
    artist = super
    artist.id = document['_id']
    artist
  end
end
