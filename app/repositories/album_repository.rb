class AlbumRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name 'albums'
  klass Album

  mapping do
    indexes :label, { type: 'object' }
    indexes :title
    indexes :notes
    indexes :tracklist_combined, { analyzer: 'snowball' }
    indexes :album_suggest, {
        type: 'object',
        properties: {
            title: { type: 'completion' },
            tracklist: { type: 'completion' }
        }
    }
  end

  def albums_by_artist(artist)
    search(query: { match: { artist_id: artist.id } })
  end

  def album_count_by_artist(artist)
    count(query: { match: { artist_id: artist.id } })
  end

  def serialize(album)
    album.validate!
    album.to_hash.tap do |hash|
      hash.merge!(artist_id: album.artist.id)
      suggest = { title: { input: [hash[:title]] } }
      suggest[:tracklist] = { input: hash[:tracklist].collect(&:strip) } if hash[:tracklist].present?
      hash.merge!(:album_suggest => suggest)
    end
  end

  def all(options = {})
    search({ query: { match_all: { } } },
           { sort: 'title' }.merge(options))
  end

  def suggest_body(term)
    {
        suggest: {
            album_title: {
                prefix: term,
                completion: { field: 'album_suggest.title', size: 25 }
            },
            album_tracklists: {
                prefix: term,
                completion: { field: 'album_suggest.tracklist', size: 25 }
            }
        }
    }
  end

  def deserialize(document)
    album = super
    album.id = document['_id']
    album
  end
end
