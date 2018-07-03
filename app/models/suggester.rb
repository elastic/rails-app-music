class Suggester
  attr_reader :response

  def initialize(params={})
    @term = params[:term]
  end

  def response
    @response ||= begin
      Elasticsearch::Persistence.client.search \
      index: Artist.index_name,
      body: {
        suggest: {
          artists: {
            prefix: @term,
            completion: { field: 'artist_suggest.name', size: 25 }
          },
          members: {
              prefix: @term,
              completion: { field: 'artist_suggest.members', size: 25 }
          },
          albums: {
            text: @term,
            completion: { field: 'album_suggest.title', size: 25 }
          }
        },
        _source: ['suggest.*']
      }
    end
  end

  def as_json(options={})
    return [] unless response['suggest']
    json = []

    if response['suggest']['artists']
      artists = response['suggest']['artists'].inject({}) do |matches, suggestion|
        suggestion['options'].each do |option|
          matches[option['_id']] = option['text']
        end
        matches
      end
      if !artists.empty?
        json << { label: 'Bands',
            value: artists.map do |d|
              { text: d[1],
                url:  "artists/#{d[0]}" }
            end
          }

      end
    end

    if response['suggest']['members']
      artists = response['suggest']['members'].inject({}) do |matches, suggestion|
        suggestion['options'].each do |option|
          matches[option['_id']] = option['text']
        end
        matches
      end
      if !artists.empty?
        json << { label: 'Band Members',
                  value: artists.map do |d|
                    { text: d[1],
                      url:  "artists/#{d[0]}" }
                  end
        }

      end
    end

    if response['suggest']['albums']
      artists = response['suggest']['albums'].inject({}) do |matches, suggestion|
        suggestion['options'].each do |option|
          matches[option['_routing']] = option['text']
        end
        matches
      end
      if !artists.empty?
        json << { label: 'Albums',
                  value: artists.map do |d|
                    { text: d[1],
                      url:  "artists/#{d[0]}" }
                  end
        }

      end
    end
    json
  end
end
