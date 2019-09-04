class HostsController < ApplicationController
  before_action :authenticate_admin!, only: [:new, :edit, :create, :update, :destroy]

  # GET /hosts
  def index
    @hosts = Host.all
  end

  # GET /hosts/:id
  def show
    @host = Host.find(params[:id])

    if Rails.env.production?
      @host.page_visits += 1
      @host.update
    end

  end

  # GET /hosts/new
  def new
    @host = Host.new({
      _hid: Host.all.size+1
    })
  end

  # GET /hosts/:id/edit
  def edit
    @host = Host.find(params[:id])
    @episodes = Episode.all.collect { |episode| [episode._eid, episode._id] }
  end

  # POST /hosts
  def create
    @host = Host.new(formatted_params)

    Host.reassign_hids

    respond_to do |format|
      if @host.save
        format.html { redirect_to dashboard_hosts_path, notice: 'Host was successfully created.' }
        format.json { render :show, status: :created, location: @host }
      else
        format.html { render :new }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hosts/:id
  def update
    @host = Host.find(params[:id])

    respond_to do |format|
      if @host.update(formatted_params)
        format.html { redirect_to dashboard_hosts_path, notice: 'Host was successfully updated.' }
        format.json { render :show, status: :ok, location: @host }
      else
        format.html { render :edit }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hosts/:id
  def destroy
    @host = Host.find(params[:id])
    @host.destroy

    Host.reassign_hids

    respond_to do |format|
      format.html { redirect_to dashboard_hosts_path, notice: 'Host was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def host_params
      params.fetch(:host, {})
    end

    def formatted_params
      {}.tap do |h|
        h[:_hid] = host_params[:_hid]
        h[:name] = host_params[:name]
        h[:titles] = host_params[:titles].split(",").map {|t| t.gsub(/\s+/, "").downcase.capitalize }
        h[:image] = host_params[:image]
        h[:bio] = host_params[:bio]
      end
    end
end
