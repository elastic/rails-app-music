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
end
