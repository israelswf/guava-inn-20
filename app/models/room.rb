class Room < ApplicationRecord
  has_many :reservations

  validates_presence_of :code, :capacity
  validates_uniqueness_of :code
  validates_numericality_of :capacity, greater_than: 0, less_than_or_equal_to: 10

  def occupancy_rate(range, room_id = id)
    start_date_range = Date.today + 1.day
    end_date_range = Date.today + range.day 
    start_date_range.to_s + " " + end_date_range.to_s

    res = Reservation.where("((start_date < ? AND end_date > ?) OR (start_date >= ? AND start_date < ?)) 
                             AND room_id = ?", start_date_range, start_date_range, start_date_range, end_date_range, room_id)

    total_days = 0
    temp = 0

    res.each do |r|

      if r.start_date <= start_date_range
          if r.end_date > end_date_range
            total_days = range
          else
            total_days += r.end_date - start_date_range
          end
      else # r.start_date >= start_date_range
        if r.end_date > end_date_range
          total_days += end_date_range - r.start_date + 1
        else
          total_days += r.end_date - r.start_date
        end
      end

    end
    
    ((total_days.to_f / range) * 100 ).round

  end

  def week_occupancy_rate
    occupancy_rate(7).to_s + "%"
  end

  def month_occupancy_rate
    occupancy_rate(30).to_s + "%"
  end

  def rooms_with_reservation
    Reservation.distinct.pluck(:room_id)
  end

  def global_occupancy_rate(range)
    if Room.any?
      total = 0    
      reservations = rooms_with_reservation

      reservations.each do |r|
        total += occupancy_rate(range, r)
      end
      total / Room.count
    else
      0
    end

  end

  def global_week_rate
    global_occupancy_rate(7).to_s + "%"
  end

  def global_month_rate
    global_occupancy_rate(30).to_s + "%" 
  end

end
