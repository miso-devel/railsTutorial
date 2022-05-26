require 'rails_helper'

RSpec.describe 'Layouts', type: :system do
  before { driven_by(:rack_test) }

  let(:user) { FactoryBot.create(:user) }

  describe 'header' do
    context 'ログイン済みの場合' do
      before do
        log_in user
        visit root_path
      end

      it 'titleをクリックするとrootに遷移すること' do
        click_link 'sample app'
        expect(page.current_path).to eq root_path
      end

      it 'Homeをクリックするとrootに遷移すること' do
        click_link 'Home'
        expect(page.current_path).to eq root_path
      end

      it 'HelpをクリックするとHelpページに遷移すること' do
        click_link 'Help'
        expect(page.current_path).to eq help_path
      end

      it 'Usersをクリックするとユーザ一覧ページに遷移すること' do
        click_link 'Users'
        expect(page.current_path).to eq users_path
      end

      context 'Account' do
        before { click_link 'Account' }

        it 'Profileをクリックするとユーザ詳細ページに遷移すること' do
          click_link 'Profile'
          expect(page.current_path).to eq user_path(user)
        end

        it 'Settingsをクリックするとユーザ編集ページに遷移すること' do
          click_link 'Settings'
          expect(page.current_path).to eq edit_user_path(user)
        end

        it 'Log outをクリックするとログアウトしてrootにリダイレクトすること' do
          click_link 'Log out'
          expect(page.current_path).to eq root_path
        end
      end
    end

    context '未ログインの場合' do
      before { visit root_path }

      it 'Homeをクリックするとrootに遷移すること' do
        click_link 'Home'
        expect(page.current_path).to eq root_path
      end

      it 'HelpをクリックするとHelpページに遷移すること' do
        click_link 'Help'
        expect(page.current_path).to eq help_path
      end

      it 'Log inをクリックするとログインページに遷移すること' do
        click_link 'Log in'
        expect(page.current_path).to eq login_path
      end
    end
  end

  describe 'footer' do
    context 'ログイン済みの場合' do
      before do
        log_in user
        visit root_path
      end

      it 'Aboutをクリックするとaboutページに遷移すること' do
        click_link 'About'
        expect(page.current_path).to eq about_path
      end

      it 'Contactをクリックするとcontactページに遷移すること' do
        click_link 'Contact'
        expect(page.current_path).to eq contact_path
      end
    end

    context '未ログインの場合' do
      before { visit root_path }

      it 'Aboutをクリックするとaboutページに遷移すること' do
        click_link 'About'
        expect(page.current_path).to eq about_path
      end

      it 'Contactをクリックするとcontactページに遷移すること' do
        click_link 'Contact'
        expect(page.current_path).to eq contact_path
      end
    end
  end
end
