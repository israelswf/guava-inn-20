class Room < ApplicationRecord
  has_many :reservations

  validates_presence_of :code, :capacity
  validates_uniqueness_of :code
  validates_numericality_of :capacity, greater_than: 0, less_than_or_equal_to: 10

  def week_occupation_rate
    "0%"
  end

  def month_occupation_rate
    "0%"
  end

end
