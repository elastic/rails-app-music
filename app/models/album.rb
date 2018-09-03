class Album
  class Validator < ActiveModel::Validator

    ERROR_MESSAGE = 'An album must be associated with an artist.'.freeze

    def validate(album)
      unless album.title && album.artist && album.artist.persisted?
        album.errors.add(:base, ERROR_MESSAGE)
      end
    end
  end
end

class Album
  include ActiveModel::Model
  include ActiveModel::Validations
  validates_with Validator

  ATTRIBUTES = [:id,
                :artist,
                :label,
                :tracklist,
                :title,
                :released,
                :notes]
  attr_accessor(*ATTRIBUTES)
  validates :title, presence: true

  def initialize(attr={})
    attr.each do |k,v|
      if ATTRIBUTES.include?(k.to_sym)
        send("#{k}=", v)
      end
    end
  end

  def attributes
    ATTRIBUTES.inject({}) do |hash, attr|
      if attr != :artist && value = send(attr)
        hash[attr] = value
      end
      hash
    end
  end
  alias :to_hash :attributes

  def id
    @id || @_id
  end

  def to_param
    id
  end

  def persisted?
    !!id
  end

  def valid?(options={})
    super
    !!(artist && artist.id)
  end
end