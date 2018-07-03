class SearchController < ApplicationController

  def index

    @artists = Artist.search({
      "query": {
          "bool": {
              "must": {
                  "multi_match": { "query": params[:q],
                                   "fields": ['name^10','members^2','profile']
                                 }
              },
              "filter": { match: { join_field: Artist::JOIN_TYPE }}
          }
      },
      highlight: {
        tags_schema: 'styled',
        fields: {
          name:    { number_of_fragments: 0 },
          members_combined: { number_of_fragments: 0 },
          profile: { fragment_size: 50 }
        }
      }
    })

    @albums = Album.search({
      "query": {
        "bool": {
                 "must": { "multi_match": {
                             "query": params[:q],
                             "fields": ['title^100','tracklist.title^10','notes^1'] } },
                 "filter": {
                   has_parent: { "parent_type": Artist::JOIN_TYPE,
                                 "query": { match_all: {} }} }
          }
      },
      highlight: {
        tags_schema: 'styled',
        fields: {
          title: { number_of_fragments: 0 },
                 'tracklist.title' => { number_of_fragments: 0 },
                 notes: { fragment_size: 50 }
          }
      }
    })
  end

  def suggest
    render json: Suggester.new(params)
  end
end
