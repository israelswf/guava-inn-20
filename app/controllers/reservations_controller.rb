class ReservationsController < ApplicationController
  def search
    @should_show_results = params[:start_date].present? &&
      params[:end_date].present? &&
      params[:number_of_guests].present?
    @available_rooms = @should_show_results ? search_avaliable_rooms : Room.none
  end

  def search_avaliable_rooms
    Room.where.not(id: rooms_already_booked).where("capacity >= ?", params[:number_of_guests])
  end

  def rooms_already_booked
    Reservation.where("start_date < ? AND end_date > ?", params[:end_date], params[:start_date]).select("room_id")
  end

  def new
    @reservation = Reservation.new(reservation_params)
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      redirect_to @reservation.room,
        notice: "Reservation #{@reservation.code} was successfully created."
    else
      render :new
    end
  end

  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy
    redirect_to room_path(@reservation.room),
      notice: "Reservation #{@reservation.code} was successfully destroyed."
  end

  private

  def reservation_params
    params.require(:reservation).permit(:start_date, :end_date, :number_of_guests, :guest_name, :room_id)
  end
end
