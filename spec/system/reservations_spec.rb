require 'rails_helper'

RSpec.describe 'Reservations', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe 'searching' do

    context 'when there are no rooms in the system' do
      before do
        Room.destroy_all
      end

      it 'shows "There are no available rooms for the selected filters"' do
        visit search_reservations_path
        click_on 'Search for Available Rooms'
        expect(page).to have_content("There are no available rooms for the selected filters")
      end
    end

    context 'when there are rooms with different capacities ' do
      before do
        Room.create!(code: '101', capacity: 1)
        Room.create!(code: '105', capacity: 5)
      end 

      it 'shows only rooms with enough capacity to accommodate number of guests' do
        visit search_reservations_path
        
        expect(page).to have_content('New Reservation')
  
        fill_in 'From', with: '2020-08-01'
        fill_in 'To', with: '2020-08-05'
        select '3', from: '# of guests'
        click_on 'Search for Available Rooms'
        
        expect(page).to have_selector('table tbody tr', count: 1)
      end
    end

=begin
    context 'when all existent rooms are already booked for given period' do

      before do
        @room = Room.create!(
          code: '105',
          capacity: '5',
          notes: 'Sparkling clean',
        )
        @room.reservations.create(
          id: 1,
          start_date: '2020-08-02',
          end_date: '2020-08-10',
          guest_name: 'João Santana',
          number_of_guests: 5,
        )
      end

      it 'shows "There are no available rooms for the selected filters"' do
        visit search_reservations_path
        fill_in 'From', with: '2020-08-02'
        fill_in 'To', with: '2020-08-10'
        select '1', from: '# of guests'
        click_on 'Search for Available Rooms'
        expect(page).to have_content("There are no available rooms for the selected filters")
      end
    end
=end

  end
end
