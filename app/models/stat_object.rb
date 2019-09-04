class StatObject
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "statistics"

  field :slug, type: String, default: ""
  field :data, type: Array, default: [] # Array of objects (data fields)

end