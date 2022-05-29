require 'rails_helper'

RSpec.describe 'AccountActivations', type: :request do
  describe '/account_activations/{id}/edit' do
    before do
      post users_path,
           params: {
             user: {
               name: 'Example User',
               email: 'user@example.com',
               password: 'password',
               password_confirmation: 'password',
             },
           }
      @user = controller.instance_variable_get('@user')
    end

    context 'トークンとemailが有効な場合' do
      it 'activateされること' do
        get edit_account_activation_path(
              @user.activation_token,
              email: @user.email,
            )
        @user.reload
        expect(@user).to be_activated
      end

      it 'ログイン状態になること' do
        get edit_account_activation_path(
              @user.activation_token,
              email: @user.email,
            )
        expect(logged_in?).to be_truthy
      end

      it 'ユーザ詳細ページにリダイレクトすること' do
        get edit_account_activation_path(
              @user.activation_token,
              email: @user.email,
            )
        expect(response).to redirect_to user_path(@user)
      end
    end

    context 'トークンとemailが無効な場合' do
      it '有効化トークンが不正ならログイン状態にならないこと' do
        get edit_account_activation_path('invalid token', email: @user.email)
        expect(logged_in?).to be_falsey
      end

      it 'メールアドレスが不正ならログイン状態にならないこと' do
        get edit_account_activation_path(@user.activation_token, email: 'wrong')
        expect(logged_in?).to be_falsey
      end
    end
  end
end
