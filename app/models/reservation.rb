class Reservation < ApplicationRecord
  belongs_to :room

  validates_presence_of :start_date, :end_date, :guest_name, :number_of_guests
  validates_numericality_of :number_of_guests, greater_than: 0, less_than_or_equal_to: 10
  validate :start_date_is_before_end_date
  validate :room_is_already_booked
  validate :exceeded_room_capacity


  def duration
    if start_date.present? && end_date.present? && end_date > start_date
      (end_date - start_date).to_i
    end
  end

  def code
    if id.present? && room&.code.present?
      formatted_id = '%02d' % id
      "#{room.code}-#{formatted_id}"
    end
  end

  def start_date_is_before_end_date
    if start_date.present? && end_date.present? && start_date >= end_date
      errors.add(:base, :invalid_dates, message: 'The start date should be before the end date')
    end
  end

  def room_is_already_booked
    already_booked = Reservation.where("start_date < ? AND end_date > ? AND room_id = ?", end_date, start_date, room_id).present?
    if already_booked
      errors.add(:base, :room_already_booked, message: "Room is already booked during this period.")
    end
  end

  def exceeded_room_capacity
    if room_id.present?
      room = Room.find(room_id)
      if number_of_guests > room.capacity
        errors.add(:base, :exceeded_room_capacity, message: "Number of guests exceeded room capacity of #{room.capacity}.")
      end
    end
  end
  
end
