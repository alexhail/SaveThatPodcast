class Episode
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  store_in collection: "episodes"

  validates_presence_of :_eid

  field :_eid,                  type: Integer, default: 0
  field :title,                 type: String, default: ""
  field :description,           type: String, default: ""
  field :color,                 type: String, default: ""
  field :date_added,            type: String, default: ""
  field :track_link,            type: String, default: ""
  field :episode_link,          type: String, default: ""
  field :parts,                 type: Array, default: []
  field :is_aggregate_episode,  type: Boolean, default: false
  field :visible,               type: Boolean, default: false
  field :guests,                type: Array, default: []
  field :hosts,                 type: Array, default: []
  field :more,                  type: Array, default: []

  # statistics
  field :page_visits,           type: Integer, default: 0

  def self.visible_fields
    ["_eid", "title", "page_visits", "date_added", "color", "is_aggregate_episode", "visible"]
  end

  def self.find_by_has_guest(gid)
    [].tap do |h|
      Episode.all.each {|e| h << e if e.guests.include?(gid) }
    end
  end
end
