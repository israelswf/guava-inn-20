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
        fill_in 'From', with: '08/02/2020'
        fill_in 'To', with: '08/10/2020'
        select '1', from: '# of guests'
        click_on 'Search for Available Rooms'
        expect(page).to have_content("There are no available rooms for the selected filters")
      end
    end

  end

  describe 'creating reservation' do

    room_capacity = 5

    before do
      @room = Room.create!(
        code: '105',
        capacity: room_capacity,
        notes: 'Sparkling clean',
      )
    end

    context 'when trying to create reservation with exceeding number of guests' do
      it 'should return the error Number of guests exceeded room capacity of 5' do
        visit new_reservation_path( reservation: {
          room_id: 1,
          start_date: '2020-08-02',
          end_date: '2020-08-10',
          number_of_guests: room_capacity,
        }) 

        fill_in 'reservation_guest_name', with: 'Bilbo Bolseiro'
        #changing select box to 8 guests
        select '8', from: 'reservation_number_of_guests'

        click_on 'Create Reservation'
        expect(page).to have_content("Number of guests exceeded room capacity of #{room_capacity}")
      end
    end

    context 'when room is reserved from 2020-08-02 to 2020-08-04' do
      before(:each) do
        @room.reservations.destroy_all

        @room.reservations.create(
          id: 1,
          start_date: '2020-08-02',
          end_date: '2020-08-04',
          guest_name: 'Carolina dos Anjos',
          number_of_guests: 3,
        )

        visit new_reservation_path( reservation: {
          room_id: 1,
          start_date: '2020-08-12',
          end_date: '2020-08-20',
          number_of_guests: room_capacity,
        })

      end

      it 'should be possible to create a reservation from 2020-08-04 to 2020-08-08' do
        fill_in 'reservation_start_date', with: '08/04/2020'
        fill_in 'reservation_end_date', with: '08/08/2020'
        fill_in 'reservation_guest_name', with: 'Bilbo Bolseiro'
        click_on 'Create Reservation'
        expect(page).to have_content("successfully created")
      end

      it 'should be possible to create a reservation from 2020-07-30 to 2020-08-02' do
        fill_in 'reservation_start_date', with: '07/30/2020'
        fill_in 'reservation_end_date', with: '08/02/2020'
        fill_in 'reservation_guest_name', with: 'Bilbo Bolseiro'
        click_on 'Create Reservation'
        expect(page).to have_content("successfully created")
      end

      it 'should not be possible to create a reservation from 2020-08-01 to 2020-08-03' do
        fill_in 'reservation_start_date', with: '08/01/2020'
        fill_in 'reservation_end_date', with: '08/03/2020'
        fill_in 'reservation_guest_name', with: 'Bilbo Bolseiro'
        click_on 'Create Reservation'
        expect(page).to have_content("Room is already booked during this period")
      end

    end
  end

end
