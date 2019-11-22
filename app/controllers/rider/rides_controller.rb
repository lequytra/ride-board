module Rider
  class RidesController < ApplicationController
    include RideManager

    # GET /rides
    # GET /rides.json
    def index
      @available_rides = future_rides
        .where.not(driver_id: nil)
        .filter {|ride| ride.seats.nil? || ride.seats > ride.passengers.count}

      @other_rides = future_rides.where(driver_id: nil)
    end

    # GET /rides/1
    # GET /rides/1.json
    def show
    end

    # GET /rides/new
    def new
      @ride = Ride.new
    end

    # GET /rides/1/edit
    def edit
    end

    # POST /rides
    # POST /rides.json
    def create
      @ride = Ride.new(rider_ride_params.merge(
        driver: nil,
        created_by: current_user,
        passengers: [current_user]
      ))

      respond_to do |format|
        if @ride.save
          format.html { redirect_to rider_ride_path(@ride),
                                    notice: 'Ride was successfully created.' }
          format.json { render :show, status: :created, location: @ride }
        else
          format.html { render :new }
          format.json { render json: @ride.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /rides/1
    # PATCH/PUT /rides/1.json
    def update
      respond_to do |format|
        if @ride.update(rider_ride_params)
          format.html { redirect_to rider_ride_path(@ride),
                                    notice: 'Ride was successfully updated.' }
          format.json { render :show, status: :ok, location: @ride }
        else
          format.html { render :edit }
          format.json { render json: @ride.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /rides/1
    # DELETE /rides/1.json
    def destroy
      @ride.destroy
      respond_to do |format|
        format.html { redirect_to rider_rides_url,
                                  notice: 'Ride was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    # POST /rides/1/join
    def join
      valid = false
      SeatAssignment.transaction do
        @ride.passengers << current_user
        valid = @ride.save
        raise ActiveRecord::Rollback unless valid
      end

      respond_to do |format|
        if valid
          format.html { redirect_to rider_ride_path(@ride),
                                    notice: 'Ride was successfully joined.' }
          format.json { render :show, status: :created, location: @ride }
        else
          @errors = @ride.errors
          @problem = "Couldn't join ride"
          format.html { render :show }
          format.json { render json: @ride.errors, status: :forbidden }
        end
      end
    end

    # DELETE /rides/1/join
    def leave
      respond_to do |format|
        SeatAssignment.transaction do
          if @ride.passengers.include? current_user
            @ride.passengers.delete current_user
            format.html { redirect_to rider_ride_path(@ride),
                                      notice: 'You have left this ride.' }
            format.json { render :show, status: :created, location: @ride }
          else
            message = 'You have already left this ride'
            format.html { render :show, notice: message }
            format.json { render json: { message: message },
                                 status: :forbidden }
          end
        end
      end
    end

    private

      def rider_ride_params
        ride_params
      end

  end
end
