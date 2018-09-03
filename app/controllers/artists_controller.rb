class ArtistsController < ApplicationController
  before_action :set_artist, only: [:show, :edit, :update, :destroy]

  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: "public/404.html", status: 404, layout: false
  end

  def index
    @artists = $artist_repository.all sort: 'name.raw'
  end

  def show
    @albums = $album_repository.albums_by_artist(@artist)
  end

  def new
    @artist = Artist.new
  end

  def create
    @artist = Artist.new(artist_params)

    respond_to do |format|
      if begin; @artist.id = $artist_repository.save(@artist, refresh: true)['_id']; rescue; false; end
        format.html { redirect_to @artist, notice: 'Artist was successfully created.' }
        format.json { render :show, status: :created, location: @artist }
      else
        format.html { render :new }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @artist_repository.delete(@artist.id, refresh: true)
    respond_to do |format|
      format.html { redirect_to artists_url, notice: 'Artist was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_artist
      @artist = $artist_repository.find(params[:id])
    end

    def artist_params
      a = params.require(:artist).permit(:name, :profile, :members, :'date(1i)', :'date(2i)', :'date(3i)')
      a[:members] = a[:members].split(/,\s?/) unless a[:members].is_a?(Array) || a[:members].blank?
      return a
    end
end
