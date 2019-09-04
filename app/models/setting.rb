class Setting
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  store_in collection: 'settings'

  validates_presence_of :slug

  field :slug, type: String, default: ""

end