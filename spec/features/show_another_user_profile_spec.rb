require 'rails_helper'

RSpec.feature 'current user visit profile of another user', type: :feature do
  let(:another_user) { create :user, name: 'Леша' }
  let(:current_user) { create :user, name: 'Миша' }
  let!(:games) do
    create(:game, user: another_user, created_at: '2022.06.01, 18:00',
                  prize: 500_000, finished_at: '2022.06.02 11:00')

    create(:game, user: another_user, created_at: '2022.06.01, 18:30',
                  prize: 125_000)
  end

  before { login_as current_user }

  feature 'correct page render' do
    before { visit '/users/1' }

    it 'should have another user name on profile page' do
      expect(page).to have_content 'Леша'
    end

    it 'should not have profile edit button' do
      expect(page).not_to have_content 'Сменить имя и пароль'
    end

    context 'and render page another user games' do
      it 'should show prizes for games' do
        expect(page).to have_content '500 000 ₽'
        expect(page).to have_content '125 000 ₽'
      end

      it 'should show correct time' do
        expect(page).to have_content '1 июня, 18:00'
        expect(page).to have_content '1 июня, 18:30'
      end

      it 'should show correct status' do
        expect(page).to have_content 'в процессе'
      end

      it 'should show correct game help' do
        expect(page).to have_content '50/50'
      end
    end
  end
end
