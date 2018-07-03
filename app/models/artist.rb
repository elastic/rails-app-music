class Artist
  include Elasticsearch::Persistence::Model

  document_type '_doc'
  index_name ArtistsAndAlbums.index_name
  class << self; delegate :create_index!, to: ArtistsAndAlbums; end

  analyzed_and_raw = { fields: {
    name: { type: 'text', analyzer: 'snowball' },
    raw:  { type: 'keyword' }
  } }

  JOIN_TYPE = 'artist'.freeze
  JOIN_METADATA = { join_field: JOIN_TYPE }.freeze

  def to_hash
    super.merge(JOIN_METADATA).tap do |hash|
      suggest = { name: { input: [name] } }
      suggest.merge!(members: { input: members.collect(&:strip) }) if members.present?
      hash.merge!(:artist_suggest => suggest)
    end
  end

  attribute :name, String, mapping: analyzed_and_raw

  attribute :profile
  attribute :date, Date

  attribute :members, String, default: [], mapping: analyzed_and_raw
  attribute :members_combined, String, default: [], mapping: { analyzer: 'snowball' }

  attribute :urls, String, default: []

  attribute :artist_suggest, Hashie::Mash, mapping: {
      type: 'object',
      properties: {
          name: { type: 'completion' },
          members: { type: 'completion' }
      }
  }

  validates :name, presence: true

  def albums
    Album.search(query: { parent_id: { type: Album::JOIN_TYPE,
                                       id: self.id } })
  end

  def album_count
    albums.size
  end

  def to_param
    id
  end

  def self.all(options = {})
    Artist.search({ query: { match: { join_field: JOIN_TYPE }}},
                  sort: 'name.raw', _source: ['name', 'album_count'])
  end

  def routing;end
end
