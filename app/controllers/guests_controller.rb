class GuestsController < ApplicationController
  before_action :authenticate_admin!, only: [:new, :edit, :create, :update, :destroy]

  # GET /guests
  def index
    @guests = Guest.all
  end

  # GET /guests/:id
  def show
    @guest = Guest.find(params[:id])
  end

  # GET /guests/new
  def new
    @guest = Guest.new({
      _gid: Guest.all.size+1
    })
  end

  # GET /guests/:id/edit
  def edit
    @guest = Guest.find(params[:id])
    @episodes = Episode.all.collect { |episode| [episode._eid, episode._id] }
  end

  # POST /guests
  def create
    @guest = Guest.new(formatted_params)

    Guest.reassign_hids

    respond_to do |format|
      if @guest.save
        format.html { redirect_to dashboard_guests_path, notice: 'Guest was successfully created.' }
        format.json { render :show, status: :created, location: @guest }
      else
        format.html { render :new }
        format.json { render json: @guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /guests/:id
  def update
    @guest = Guest.find(params[:id])

    respond_to do |format|
      if @guest.update(formatted_params)
        format.html { redirect_to dashboard_guests_path, notice: 'Guest was successfully updated.' }
        format.json { render :show, status: :ok, location: @guest }
      else
        format.html { render :edit }
        format.json { render json: @guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guests/:id
  def destroy
    @guest = Guest.find(params[:id])
    @guest.destroy

    Guest.reassign_hids

    respond_to do |format|
      format.html { redirect_to dashboard_guests_path, notice: 'Guest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def guest_params
      params.fetch(:guest, {})
    end

    def formatted_params
      {}.tap do |g|
        g[:_gid] = guest_params[:_gid]
        g[:name] = guest_params[:name]
        g[:titles] = guest_params[:titles].split(",").map {|t| t.gsub(/\s+/, "").downcase.capitalize }
        g[:image] = guest_params[:image]
        g[:bio] = guest_params[:bio]
      end
    end
end
