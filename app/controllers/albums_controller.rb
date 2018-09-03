class AlbumsController < ApplicationController

  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: "public/404.html", status: 404, layout: false
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(album_params)
    artist = $artist_repository.find(album_params[:artist])
    @album.artist = artist if artist

    respond_to do |format|
      if begin; @album.id = $album_repository.save(@album, refresh: true)['_id']; rescue; false; end
        format.html { redirect_to artist, notice: 'Album was successfully created.' }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { render :new }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def album_params
    params.require(:album).permit(:title, :artist)
  end
end
