require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  let(:user) { FactoryBot.create(:user) }

  before { ActionMailer::Base.deliveries.clear }

  describe '#new' do
    it 'password_reset[email]というname属性のinputタグが表示されること' do
      get new_password_reset_path
      expect(response.body).to include "name=\"password_reset[email]\""
    end
  end

  describe '#create' do
    it '無効なメールアドレスならflashが存在すること' do
      post password_resets_path, params: { password_reset: { email: '' } }
      expect(flash).to_not be_empty
    end

    context '有効なメールアドレスの場合' do
      it 'reset_digestが変わっていること' do
        post password_resets_path,
             params: {
               password_reset: {
                 email: user.email,
               },
             }
        expect(user.reset_digest).to_not eq user.reload.reset_digest
      end

      it '送信メールが1件増えること' do
        expect {
          post password_resets_path,
               params: {
                 password_reset: {
                   email: user.email,
                 },
               }
        }.to change(ActionMailer::Base.deliveries, :count).by 1
      end

      it 'flashが存在すること' do
        post password_resets_path,
             params: {
               password_reset: {
                 email: user.email,
               },
             }
        expect(flash).to_not be_empty
      end

      it 'rootにリダイレクトされること' do
        post password_resets_path,
             params: {
               password_reset: {
                 email: user.email,
               },
             }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#edit' do
    before do
      post password_resets_path,
           params: {
             password_reset: {
               email: user.email,
             },
           }
      @user = controller.instance_variable_get('@user')
    end

    it 'メールアドレスもトークンも有効なら、隠しフィールドにメールアドレスが表示されること' do
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      expect(
        response.body,
      ).to include "<input type=\"hidden\" name=\"email\" id=\"email\" value=\"#{@user.email}\" autocomplete=\"off\" />"
    end

    it 'メールアドレスが間違っていれば、rootにリダイレクトすること' do
      get edit_password_reset_path(@user.reset_token, email: '')
      expect(response).to redirect_to root_path
    end

    it '無効なユーザならrootにリダイレクトすること' do
      @user.toggle!(:activated)
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      expect(response).to redirect_to root_path
    end

    it 'トークンが無効なら、rootにリダイレクトすること' do
      get edit_password_reset_path('wrong token', email: @user.email)
      expect(response).to redirect_to root_path
    end

    it '2時間以上経過していれば、newにリダイレクトされること' do
      @user.update_attribute(:reset_sent_at, 3.hours.ago)
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      expect(response).to redirect_to new_password_reset_path
    end
  end

  describe '#update' do
    before do
      post password_resets_path,
           params: {
             password_reset: {
               email: user.email,
             },
           }
      @user = controller.instance_variable_get('@user')
    end

    context '有効なパスワードの場合' do
      it 'ログイン状態になること' do
        patch password_reset_path(@user.reset_token),
              params: {
                email: @user.email,
                user: {
                  password: 'foobaz',
                  password_confirmation: 'foobaz',
                },
              }
        expect(logged_in?).to be_truthy
      end

      it 'flashが存在すること' do
        patch password_reset_path(@user.reset_token),
              params: {
                email: @user.email,
                user: {
                  password: 'foobaz',
                  password_confirmation: 'foobaz',
                },
              }
        expect(flash).to_not be_empty
      end

      it 'ユーザの詳細ページにリダイレクトすること' do
        patch password_reset_path(@user.reset_token),
              params: {
                email: @user.email,
                user: {
                  password: 'foobaz',
                  password_confirmation: 'foobaz',
                },
              }
        expect(response).to redirect_to @user
      end
      it 'reset_digestがnilになること' do
        patch password_reset_path(@user.reset_token),
              params: {
                email: @user.email,
                user: {
                  password: 'foobaz',
                  password_confirmation: 'foobaz',
                },
              }
        @user.reload
        expect(@user.reset_digest).to be_nil
      end
    end

    it 'パスワードと再入力が一致しなければ、エラーメッセージが表示されること' do
      patch password_reset_path(@user.reset_token),
            params: {
              email: @user.email,
              user: {
                password: 'foobaz',
                password_confirmation: 'barquux',
              },
            }
      expect(response.body).to include "<div class=\"error_messages\">"
    end

    it 'パスワードが空なら、エラーメッセージが表示されること' do
      patch password_reset_path(@user.reset_token),
            params: {
              email: @user.email,
              user: {
                password: '',
                password_confirmation: '',
              },
            }
      expect(response.body).to include "<div class=\"error_messages\">"
    end

    context '2時間以上経過している場合' do
      before { @user.update_attribute(:reset_sent_at, 3.hours.ago) }

      it 'newにリダイレクトされること' do
        patch password_reset_path(@user.reset_token),
              params: {
                email: @user.email,
                user: {
                  password: 'foobaz',
                  password_confirmation: 'foobaz',
                },
              }
        expect(response).to redirect_to new_password_reset_path
      end

      it '"Password reset has expired."が表示されること' do
        patch password_reset_path(@user.reset_token),
              params: {
                email: @user.email,
                user: {
                  password: 'foobaz',
                  password_confirmation: 'foobaz',
                },
              }
        follow_redirect!
        expect(response.body).to include 'Password reset has expired.'
      end
    end
  end
end
