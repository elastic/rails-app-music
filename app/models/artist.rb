class Artist
  include ActiveModel::Model
  include ActiveModel::Validations

  ATTRIBUTES = [:name,
                :id,
                :_id,
                :profile,
                :date,
                :members,
                :members_combined,
                :urls]
  attr_accessor(*ATTRIBUTES)
  attr_reader :attributes

  validates :name, presence: true

  def initialize(attr={})
    attr.each do |k,v|
      if ATTRIBUTES.include?(k.to_sym)
        send("#{k}=", v)
      end
    end
  end

  def attributes
    ATTRIBUTES.inject({}) do |hash, attr|
      if value = send(attr)
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

  def members(mems = nil)
    return @members = mems if mems
    @members ||= []
  end
end
