class Suggester
  attr_reader :response

  def initialize(params={})
    @term = params[:term]
  end

  def response
    @response ||= begin
      Elasticsearch::Persistence.client.search \
      index: Album.index_name,
      body: {
        suggest: {
            suggest_albums: {
                prefix: @term,
                completion: { field: 'suggest.album_title', size: 25 }
            },
            suggest_members: {
                prefix: @term,
                completion: { field: 'suggest.artist_members', size: 25 }
            },
            suggest_artists: {
                prefix: @term,
                completion: { field: 'suggest.artist_name', size: 25 }
            }
        },
        _source: ['suggest.*']
      }
    end
  end

  def as_json(options={})
    return [] unless response['suggest']
    json = []

    if response['suggest']['suggest_artists']
      artists = response['suggest']['suggest_artists'].inject({}) do |matches, suggestion|
        suggestion['options'].each do |option|
          matches[option['_source']['suggest']['artist_name']['input'][1]] = option['text']
        end
        matches
      end
    end

    if response['suggest']['suggest_members']
      artists.merge!(response['suggest']['suggest_members'].inject({}) do |matches, suggestion|
        suggestion['options'].each do |option|
          matches[option['_source']['suggest']['artist_name']['input'][1]] = option['_source']['suggest']['artist_name']['input'][0]
        end
        matches
      end)
    end

    if !artists.empty?
      json << { label: 'Bands',
                value: artists.map do |id, name|
                  { text: name,
                    url:  "artists/#{id}" }
                end }

    end

    if response['suggest']['suggest_albums']
      albums = response['suggest']['suggest_albums'].inject({}) do |matches, suggestion|
        suggestion['options'].each do |option|
          matches[option['_source']['suggest']['artist_name']['input'][1]] = option['text']
        end
        matches
      end
    end

    if !albums.empty?
      json << { label: 'Albums',
                value: albums.map do |id, name|
                  { text: name,
                    url:  "artists/#{id}" }
                end }

    end
    json
  end
end
