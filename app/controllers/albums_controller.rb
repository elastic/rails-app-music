class AlbumsController < ApplicationController

  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: "public/404.html", status: 404, layout: false
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(album_params)
    artist = Artist.find(album_params[:artist])
    @album.artist = artist if artist

    respond_to do |format|
      if @album.save refresh: true
        format.html { redirect_to artist, notice: 'Album was successfully created.' }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { render :new }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @artist = @album.artist
  end

  private

  def album_params
    params.require(:album).permit(:title, :artist)
  end
end
