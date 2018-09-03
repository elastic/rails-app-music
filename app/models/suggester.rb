class Suggester
  attr_reader :response

  def initialize(params={})
    @term = params[:term]
  end

  def execute!(*repositories)
    @responses ||= []
    repositories.each do |repository|
      @responses << begin
        repository.client.search(index: repository.index_name,
                                 body: repository.suggest_body(@term))
      end
    end
  end

  def as_json(options={})
    json = []
    @responses.each do |response|
      results = {}
      next unless response['suggest']
      ['artist_names', 'artist_members', 'album_title', 'album_tracklist'].each do |result_field|

        if suggestion = response['suggest'][result_field]
          results.merge!(suggestion.inject({}) do |matches, suggestion|
            suggestion['options'].each do |option|
              matches[option['text']] = option['_source']['artist_id'] || option['_id']
            end
            matches
          end)
        end
      end

      if !results.empty?
        json << { label: 'Matches',
                  value: results.map do |matching_text, artist_id|
                    { text: matching_text,
                      url:  "artists/#{artist_id}" }
                  end }

      end
    end
    json
  end
end
