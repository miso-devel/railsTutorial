RSpec.describe 'Users', type: :system do
  before { driven_by(:rack_test) }

  describe '#create' do
    context '無効な値の場合' do
      it 'エラーメッセージ用の表示領域が描画されていること' do
        visit signup_path
        fill_in 'Name', with: ''
        fill_in 'Email', with: 'user@invlid'
        fill_in 'Password', with: 'foo'
        fill_in 'Confirmation', with: 'bar'
        click_button 'Create my account'

        expect(page).to have_selector 'div.error'
        expect(page).to have_selector 'div.error_messages'
      end
    end
  end
  describe '#index' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:other_user) }

    it 'adminユーザならdeleteリンクが表示されること' do
      log_in user
      visit users_path

      expect(page).to have_button 'delete'
    end

    it 'adminユーザでなければdeleteリンクが表示されないこと' do
      log_in other_user
      visit users_path

      expect(page).to_not have_button 'delete'
    end
  end
end
