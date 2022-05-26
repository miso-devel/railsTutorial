require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe '正常にレスポンスを返すこと' do
    it 'returns http success' do
      get '/signup'
      expect(response).to have_http_status(:success)
    end
    describe 'pagination' do
      let(:user) { FactoryBot.create(:user) }
      before do
        30.times { FactoryBot.create(:continuous_users) }
        log_in user
        get users_path
      end

      it 'div.paginationが存在すること' do
        expect(
          response.body,
        ).to include '<div role="navigation" aria-label="Pagination" class="pagination">'
      end

      it 'ユーザごとの名前' do
        User
          .paginate(page: 1)
          .each { |user| expect(response.body).to include "#{user.name}" }
      end
    end
  end
  describe 'POST /users #create' do
    it '無効な値だと登録されないこと' do
      expect {
        post users_path,
             params: {
               user: {
                 name: '',
                 email: 'user@invlid',
                 password: 'foo',
                 password_confirmation: 'bar',
               },
             }
      }.to_not change(User, :count)
    end
  end

  describe 'get /users/{id}/edit' do
    let(:user) { FactoryBot.create(:user) }
    context '有効な値の場合' do
      let(:user_params) do
        {
          user: {
            name: 'Example User',
            email: 'user@example.com',
            password: 'password',
            password_confirmation: 'password',
          },
        }
      end

      it '登録されること' do
        expect { post users_path, params: user_params }.to change(
          User,
          :count,
        ).by 1
      end

      it 'users/showにリダイレクトされること' do
        post users_path, params: user_params
        user = User.last
        expect(response).to redirect_to user
      end

      it 'flashが表示されていること' do
        post users_path, params: user_params
        expect(flash).to be_any
      end

      it 'ログイン状態であること' do
        post users_path, params: user_params
        expect(logged_in?).to be_truthy
      end

      context '別のユーザの場合' do
        let(:other_user) { FactoryBot.create(:other_user) }

        it 'flashが空であること' do
          log_in(other_user)
          get edit_user_path(other_user)
          expect(flash).to be_empty
        end

        it 'root_pathにリダイレクトされること' do
          log_in(user)
          get edit_user_path(other_user)
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  # edit
  describe 'PATCH /users' do
    let(:user) { FactoryBot.create(:user) }

    it 'editページレスポンスが200であること' do
      log_in(user)
      get edit_user_path(user)
      expect(response.body).to include 'Users#edit'
    end

    context '無効な値の場合' do
      before do
        log_in(user)
        patch user_path(user),
              params: {
                user: {
                  name: '',
                  email: 'foo@invlid',
                  password: 'foo',
                  password_confirmation: 'bar',
                },
              }
      end

      it '更新できないこと' do
        user.reload
        expect(user.name).to_not eq ''
        expect(user.email).to_not eq ''
        expect(user.password).to_not eq 'foo'
        expect(user.password_confirmation).to_not eq 'bar'
      end

      it 'The form contains 4 errors.と表示されていること' do
        expect(response.body).to include 'The form contains 4 errors.'
      end

      it '更新アクション後にeditのページが表示されていること' do
        expect(
          response.body,
        ).to include '<h1 class="font-bold text-4xl">Users#edit</h1>'
      end
    end
    context '有効な値の場合' do
      before do
        log_in(user)
        @name = 'Foo Bar'
        @email = 'foo@bar.com'
        patch user_path(user),
              params: {
                user: {
                  name: @name,
                  email: @email,
                  password: '',
                  password_confirmation: '',
                },
              }
      end

      it '更新できること' do
        user.reload
        expect(user.name).to eq @name
        expect(user.email).to eq @email
      end

      it 'Users#showにリダイレクトすること' do
        expect(response).to redirect_to user
      end

      it 'flashが表示されていること' do
        expect(flash).to be_any
      end
    end
    context '未ログインの場合' do
      it 'flashが空でないこと' do
        patch user_path(user),
              params: {
                user: {
                  name: user.name,
                  email: user.email,
                },
              }
        expect(flash).to_not be_empty
      end

      it '未ログインユーザはログインページにリダイレクトされること' do
        patch user_path(user),
              params: {
                user: {
                  name: user.name,
                  email: user.email,
                },
              }
        expect(response).to redirect_to login_path
      end

      it 'ログインすると編集ページにリダイレクトされること' do
        get edit_user_path(user)
        log_in user
        expect(response).to redirect_to edit_user_path(user)
      end

      it 'session[:forwarding_url]がデフォルトに戻るのか' do
        get edit_user_path(user)
        log_in user
        expect(response).to redirect_to edit_user_path(user)
        delete logout_path
        log_in user
        expect(response).to redirect_to user_path(user)
      end
    end

    context '不正アクセスができないようにする' do
      let(:other_user) { FactoryBot.create(:other_user) }
      it 'adminが不正に変えられない' do
        log_in(other_user)
        patch user_path(other_user),
              params: {
                user: {
                  password: 'password2',
                  password_confirmation: 'password2',
                  admin: true,
                },
              }
        other_user.reload
        expect(other_user.admin).to eq false
      end
    end
  end
  describe 'DELETE /users/{id}' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:other_user) }

    context '未ログインの場合' do
      it '削除できないこと' do
        expect { delete user_path(user) }.to_not change(User, :count)
      end

      it 'ログインページにリダイレクトすること' do
        delete user_path(user)
        expect(response).to redirect_to login_path
      end
    end

    context 'adminユーザでない場合' do
      it '削除できないこと' do
        log_in other_user
        expect { delete user_path(user) }.to_not change(User, :count)
      end

      it 'rootにリダイレクトすること' do
        log_in other_user
        delete user_path(user)
        expect(response).to redirect_to root_path
      end
    end

    context 'adminユーザでログイン済みの場合' do
      it '削除できること' do
        log_in user
        expect { delete user_path(other_user) }.to change(User, :count).by -1
      end
    end
  end
end
