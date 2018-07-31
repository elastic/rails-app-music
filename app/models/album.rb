class Album
  include Elasticsearch::Persistence::Model

  document_type '_doc'
  index_name 'artists_and_albums'

  attribute :artist
  attribute :artist_id, String, mapping: { type: 'keyword' }

  attribute :title, String, mapping: { type: 'keyword' }
  attribute :released, Date

  validates :title, presence: true

  attribute :suggest, Hashie::Mash, mapping: {
      type: 'object',
      properties: {
          album_title: { type: 'completion' },
          artist_name: { type: 'completion' },
          artist_members: { type: 'completion' }
      }
  }

  def to_hash
    super.tap do |hash|
      hash.delete(:artist)
      hash.merge!(artist_id: artist.id)
      suggest = { album_title: { input: [title] } }
      suggest[:artist_name] = { input: [artist.name, artist.id] }
      suggest[:artist_members] = { input: artist.members.collect(&:strip) }
      hash.merge!(:suggest => suggest)
    end
  end

  def valid?(options={})
    super
    !!(artist && artist.id)
  end

  def artist_id
    @artist_id || (@artist && @artist.id)
  end

  def artist
    @artist || (artist_id && Artist.find(artist_id))
  end

  def artist_name
    (artist && artist.name) || Artist.find(artist_id).name
  rescue
    ''
  end

  def self.all(options = {})
    Album.search({ query: { match_all: { }}},
                   sort: 'title')
  end
end
