require 'rails_helper'

RSpec.describe Room, type: :model do
  it 'validates presence of code' do
    room = Room.new

    expect(room).to_not be_valid
    expect(room).to have_error_on(:code, :blank)
  end

  it 'validates uniqueness of code' do
    Room.create!(code: '101', capacity: 2)

    room = Room.new(code: '101')
    expect(room).to_not be_valid
    expect(room).to have_error_on(:code, :taken)
  end

  it 'validates presence of capacity' do
    room = Room.new

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :blank)
  end

  it 'validates that capacity should not be zero' do
    room = Room.new(capacity: 0)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :greater_than)
  end

  it 'validates that capacity should not be negative' do
    room = Room.new(capacity: -1)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :greater_than)
  end

  it 'validates that capacity should not be greater than ten' do
    room = Room.new(capacity: 11)

    expect(room).to_not be_valid
    expect(room).to have_error_on(:capacity, :less_than_or_equal_to)
  end

  it 'validates that initial week occupancy rate is 0%' do
    room = Room.new
    expect(room.week_occupancy_rate).to eq('0%')
  end

  it 'validates that initial month occupancy rate is 0%' do
    room = Room.new
    expect(room.month_occupancy_rate).to eq('0%')
  end

  context 'when room is fully booked for the week' do
    it 'validates that week occupancy rate is 100%' do

      start_date = Date.today + 1.day
      end_date = Date.today + 8.day
      guest_name = 'João Santana',
      number_of_guests = 1

      room = Room.create!(code: '105', capacity: 5)
      room.reservations.create!(start_date: start_date, end_date: end_date, 
        guest_name: guest_name, number_of_guests: number_of_guests)
      expect(room.week_occupancy_rate).to eq('100%')
    end
  end

  context 'when room is fully booked for the month' do
    it 'validates that month occupancy rate is 100%' do

      start_date = Date.today + 1.day
      end_date = Date.today + 31.day
      guest_name = 'João Santana',
      number_of_guests = 1

      room = Room.create!(code: '105', capacity: 5)
      room.reservations.create!(start_date: start_date, end_date: end_date, 
        guest_name: guest_name, number_of_guests: number_of_guests)
      expect(room.month_occupancy_rate).to eq('100%')
    end
  end

end
