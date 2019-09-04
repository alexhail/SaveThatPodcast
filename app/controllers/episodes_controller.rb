require 'yaml'

class EpisodesController < ApplicationController
  before_action :authenticate_admin!, only: [:new, :edit, :create, :update, :destroy]
  before_action :get_episode, only: [:show, :edit, :update, :destroy, :remove_hosts_guests, 
    :add_part, :remove_part, :add_more, :remove_link, :remove_picture]

  # GET /episodes
  def index
    unless admin_signed_in?
      @episodes = Episode.where(visible: true)
    else
      @episodes = Episode.all
    end
  end

  # GET /episodes/:id
  def show
    if Rails.env.production? 
      @episode.page_visits += 1
      @episode.update
    end

    @episode_links = @episode.more.inject([]) {|memo, m| m["type"] == "link" ? memo << m : memo }
    @episode_pictures = @episode.more.inject([]) {|memo, m| m["type"] == "picture" ? memo << m : memo }
  end

  # GET /episodes/:id/edit
  def edit
    host_ids = Host.all.inject([]) {|memo, host| memo << host._id.to_s }

    @guest_options = Guest.all.inject([]) {|memo, guest| memo << [guest.name, guest._id] }.unshift([" - ", 0])
    @host_options = Host.all.inject([]) {|memo, host| 
      memo << [host.name, host._id] 
    }.unshift([" - ", 0]).push(["All Hosts", host_ids])
    
    empty_candidates = ["guests", "hosts", "color", "date_added", "title", "parts", "description", "more"]
    non_text_fields = ["parts", "guests", "hosts", "more"]

    # Reject, select, inject, bro
    @empty_fields = @episode.attributes.reject { |k, v|
     !empty_candidates.include?(k) 
    }.select { |k, v|
      k if v.empty?
    }.inject([]) { |memo, (k, v)|
      unless non_text_fields.include?(k)
        if k == "description" && @episode.is_aggregate_episode
          memo
        else
          memo << k.split("_").each_with_index { |x, i|
            x.capitalize! if i == 0
          }.join(" ") + " field is empty"
        end
      else
        if k == "parts"
          memo.tap do |m|
            m << k.capitalize + " list is empty" if @episode.is_aggregate_episode
          end
        else
          memo << k.capitalize + " list is empty"
        end
      end
    }

    @parts_options = @episode.parts.size > 0 ? [*1..@episode.parts.size] : [*"No parts"]
    @episode_links = @episode.more.inject([]) {|memo, m| m["type"] == "link" ? memo << m : memo }
    @episode_pictures = @episode.more.inject([]) {|memo, m| m["type"] == "picture" ? memo << m : memo }
  end

  # POST /episodes
  def create
    @episode = Episode.new({
      date_added: DateTime.now.beginning_of_day.strftime("%e %b %Y")
    })

    respond_to do |format|
      if @episode.save
        format.html { redirect_to edit_episode_path(@episode._id), notice: 'Episode was successfully created.' }
        format.json { render :show, status: :created, location: @episode }
      else
        format.html { render :new }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /episodes/:id
  # TODO XXX Need to move the remove guests and hosts functionality to a different action
  def update

    if params[:new_host].present?
      array = YAML.load(params[:new_host])

      # Handle new hosts
      # Check if its an array of hosts IDs
      if array.is_a?(Array) && array.length > 1
        array.each do |id|
          unless @episode.hosts.include?(BSON::ObjectId(id))
            @episode.hosts.push(BSON::ObjectId(id)) if id.to_i != 0
          end
        end
      else
        unless params[:new_host].to_i == 0
          unless @episode.hosts.include?(BSON::ObjectId(params[:new_host]))
            @episode.hosts.push(BSON::ObjectId(params[:new_host])) if params[:new_host].to_i != 0
          end
        end
      end

      # Handle new guest
      @episode.guests.push(BSON::ObjectId(params[:new_guest])) if params[:new_guest].present? && params[:new_guest].to_i != 0

      @episode.update
    end
    
    respond_to do |format|
      if @episode.update_attributes(episode_params(@episode))

        # Check _eid when episode visible
        unless @episode._eid > 0
          if @episode.visible?
            @episode._eid = Episode.all.order_by(_eid: :desc).first._eid + 1
          end
        end

        # Handle aggregate episode part updates
        if @episode.is_aggregate_episode
          @episode.parts.each_with_index do |part, index|
            part.keys.each do |key|
              part["#{key}"] = params["part_#{index}_#{key}"]
            end
          end
        end

        # Second update after we've updated with our strong params
        @episode.update

        format.html { redirect_to edit_episode_path, notice: "Episode "+@episode._eid.to_s+" updated successfully." }
        format.json { render :show, status: :ok, location: @episode }
      else
        format.html { render :edit }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /episodes/:id/remove_hosts_guests
  def remove_hosts_guests

    # Handle remove host
    @episode.hosts.delete(BSON::ObjectId(params[:remove_host])) if params[:remove_host].present? && params[:remove_host].to_i != 0

    # Handle remove guest
    @episode.guests.delete(BSON::ObjectId(params[:remove_guest])) if params[:remove_guest].present? && params[:remove_guest].to_i != 0

    if params[:remove_all_hosts].present? && params[:remove_all_hosts]
       @episode.hosts.clear
    end

    if @episode.update
        redirect_to edit_episode_path(params[:id]), notice: 'Successfully added hosts/guests to Episode '+@episode._eid.to_s
      else
        redirect_to edit_episode_path(params[:id]), alert: 'Episode did not update correctly.'
      end
  end

  # PATCH /episodes/:id/add_part
  def add_part
    # Add empty part to episode
    @episode.parts.push({
      "title" => "",
      "date_added" => "",
      "description" => "",
      "episode_link" => "",
      "track_link" => "",
    })

    if @episode.update
      redirect_to edit_episode_path(params[:id]), notice: 'Successfully added part to Episode '+@episode._eid.to_s
    else
      redirect_to edit_episode_path(params[:id]), alert: 'Error adding part to Episode '+@episode._eid.to_s
    end
  end

  # PATCH /episodes/:id/remove_part/:index
  def remove_part
    # Add empty part to episode
    @episode.parts.slice!(params[:index].to_i - 1)

    if @episode.update
      redirect_to edit_episode_path(params[:id]), notice: 'Successfully removed part from Episode '+@episode._eid.to_s
    else
      redirect_to edit_episode_path(params[:id]), alert: 'Error removing part from Episode '+@episode._eid.to_s
    end
  end

  # PATCH /episodes/:id/add_more
  def add_more

    # Add more to episode
    url = params[:url]
    url = "https://#{url}" unless url.match(/^https?:\/\//)

    unless params[:title].empty? || params[:url].empty?
      @episode.more.push({
        "type" => params[:type],
        "title" => params[:title],
        "url" => url,
        "description" => params[:description]
      })

      if @episode.update
        redirect_to edit_episode_path(params[:id]), notice: 'Successfully attached '+params[:type]+' to Episode '+@episode._eid.to_s
      else
        redirect_to edit_episode_path(params[:id]), alert: 'Error attaching '+params[:type]+' to Episode '+@episode._eid.to_s
      end
    else
      redirect_to edit_episode_path(params[:id]), alert: 'You had blank fields in your attachment form'
    end
  end

  # PATCH /episodes/:id/remove_link
  def remove_link
    links_count = @episode.more.collect {|m| m["type"] == "link" }.length
    i = params[:index].to_i

    unless i < 0 || i > links_count
      @episode.more.slice!(i)
    end

    @episode.update
  end

  # PATCH /episodes/:id/remove_picture
  def remove_picture
    pictures_count = @episode.more.collect {|m| m["type"] == "picture" }.length
    i = params[:index].to_i
    
    unless i < 0 || i > pictures_count
      @episode.more.slice!(i)
    end

    @episode.update
  end

  # DELETE /episodes/:id
  def destroy
    @episode.destroy

    respond_to do |format|
      format.html { redirect_to dashboard_episodes_path, notice: 'Episode was successfully destroyed' }
      format.json { head :no_content }
    end
  end

  private

  def get_episode
    @episode = Episode.find(params[:id].to_oid_safe)
  end

  # only permit episode fields
  def episode_params(episode)
    merge = []

    episode.parts.each_with_index do |p, i|
      merge.concat([
        "part_#{i}_title".to_sym,
        "part_#{i}_date_added".to_sym,
        "part_#{i}_description".to_sym,
        "part_#{i}_episode_link".to_sym,
        "part_#{i}_track_link".to_sym
      ])
    end

    params.require(:episode).permit(Episode.fields.keys.concat(merge))
  end
end
