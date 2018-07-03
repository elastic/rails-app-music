class ArtistsAndAlbums
  include Elasticsearch::Persistence::Model

  index_name 'artists_and_albums'
  document_type '_doc'

  def self.create_index!(options={})
    client = Artist.gateway.client
    client.indices.delete index: index_name rescue nil if options[:force]

    settings = Artist.settings.to_hash.merge Album.settings.to_hash
    mapping_properties = { join_field: { type: 'join',
                                         relations: { Artist::JOIN_TYPE => Album::JOIN_TYPE } } }

    merged_properties = mapping_properties.merge(Artist.mappings.to_hash[:_doc][:properties]).merge(
        Album.mappings.to_hash[:_doc][:properties])
    mappings = { _doc: { properties: merged_properties }}

    client.indices.create index: index_name,
                          body: {
                              settings: settings.to_hash,
                              mappings: mappings }
  end
end
