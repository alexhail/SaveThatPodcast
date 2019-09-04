class Host
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  store_in collection: "hosts"

  validates_presence_of :_hid

  field :_hid, type: Integer, default: 0          # Host specific ID (Should match order of creation)
  field :name, type: String, default: ""          # The hosts full name
  field :titles, type: Array, default: []         # Array of titles for the host, Rapper, Programmer, Artist, Podcaster, etc
  field :bio, type: String, default: ""
  field :image, type: String, default: ""

  # statistics
  field :page_visits,           type: Integer, default: 0

  def self.reassign_hids
    Host.all.each_with_index {|host, idx| host.update({ _hid: idx+1 }) }
  end
end
