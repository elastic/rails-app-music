class Album
  include Elasticsearch::Persistence::Model

  document_type '_doc'
  index_name ArtistsAndAlbums.index_name
  class << self; delegate :create_index!, to: ArtistsAndAlbums; end

  JOIN_TYPE = 'album'.freeze
  ROUTING_RESPONSE_FIELD = '_routing'.freeze

  attribute :artist, Object, mapping: { index: false }
  attribute :artist_id, String, mapping: { index: false }
  attribute :label, Hash, mapping: { type: 'object' }
  attribute :tracklist, Array, mapping: { type: 'object' }

  attribute :title
  attribute :released, Date
  attribute :notes
  attribute :uri


  validates :title, presence: true

  attribute :album_suggest, Hashie::Mash, mapping: {
      type: 'object',
      properties: {
          title: { type: 'completion' }
      }
  }

  def to_hash
    super.merge(join_field: { 'name' => JOIN_TYPE, 'parent' => artist.id }).tap do |hash|
      hash.delete(:artist)
      hash.delete(:artist_id)
      hash.merge!(:album_suggest => { title: { input: [title] } })
    end
  end

  def save(options = {})
    return unless valid?
    super(options.merge(routing: routing))
  end

  def routing
    artist.id
  end

  def valid?(options={})
    super
    !!(artist && artist.id)
  end

  def artist_id
    hit && hit[ROUTING_RESPONSE_FIELD]
  rescue
  end

  def artist_name
    Artist.find(artist_id).name
  rescue
    ''
  end
end
