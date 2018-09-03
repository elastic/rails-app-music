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
end
