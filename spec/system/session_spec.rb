require 'rails_helper'

RSpec.describe 'Sessions', type: :system do
  before { driven_by(:rack_test) }

  describe '#new' do
    context '無効な値の場合' do
      it 'flashメッセージが表示される' do
        visit login_path

        fill_in 'Email', with: ''
        fill_in 'Password', with: ''
        click_button 'Log in'

        expect(page).to have_selector 'div.alert.alert-danger'

        visit root_path
        expect(page).to_not have_selector 'div.alert.alert-danger'
      end
    end
  end

  describe '#new' do
    context '有効な値の場合' do
      let(:user) { FactoryBot.create(:user) }

      it 'ログインユーザ用のページが表示されること' do
        visit login_path

        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Log in'

        expect(page).to_not have_selector "a[href=\"#{login_path}\"]"
        expect(page).to have_selector "a[href=\"#{logout_path}\"]"
        expect(page).to have_selector "a[href=\"#{user_path(user)}\"]"
      end
    end
    context '無効な値の場合' do
      let(:user) { FactoryBot.create(:user) }

      it 'ログインユーザ用のページが表示されること' do
        visit login_path

        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'passssssss'
        click_button 'Log in'

        visit login_path
        expect(page).to have_selector "a[href=\"#{login_path}\"]"
        expect(page).to_not have_selector "a[href=\"#{logout_path}\"]"
        expect(page).to_not have_selector "a[href=\"#{user_path(user)}\"]"
      end
    end
  end
end
