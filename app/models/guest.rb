class Guest
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  store_in collection: "guests"

  validates_presence_of :_gid

  field :_gid, type: Integer, default: 0           # Guest specific ID (Should match order of creation)
  field :name, type: String, default: "<noname>"  # The guests full name
  field :titles, type: Array, default: []         # Array of titles for the guest, Rapper, Programmer, Artist, Podcaster, etc
  field :bio, type: String, default: ""
  field :image, type: String, default: ""

  # statistics
  field :page_visits,           type: Integer, default: 0

  def self.reassign_hids
    Guest.all.each_with_index {|guest, idx| guest.update({ _gid: idx+1 }) }
  end
end
