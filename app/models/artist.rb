class Artist
  include Elasticsearch::Persistence::Model

  document_type '_doc'
  index_name 'artists'

  analyzed_and_raw = { fields: {
    name: { type: 'text', analyzer: 'snowball' },
    raw:  { type: 'keyword' }
  } }

  def to_hash
    super.tap do |hash|
      suggest = { name: { input: [name] } }
      suggest.merge!(members: { input: members.collect(&:strip) }) if members.present?
      hash.merge!(:artist_suggest => suggest)
    end
  end

  attribute :name, String, mapping: analyzed_and_raw
  attribute :profile
  attribute :members, String, default: [], mapping: analyzed_and_raw
  attribute :artist_suggest, Hashie::Mash, mapping: {
      type: 'object',
      properties: {
          name: { type: 'completion' },
          members: { type: 'completion' }
      }
  }

  validates :name, presence: true

  def albums
    Album.search(query: { match: { artist_id: self.id } })
  end

  def album_count
    albums.size
  end

  def to_param
    id
  end

  def self.all(options = {})
    Artist.search({ query: { match_all: { } } },
                  sort: 'name.raw')
  end
end
