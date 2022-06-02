require 'rails_helper'

RSpec.describe 'Microposts', type: :request do
  describe '#create' do
    context '未ログインの場合' do
      it '登録されないこと' do
        expect {
          post microposts_path,
               params: {
                 micropost: {
                   content: 'Lorem ipsum',
                 },
               }
        }.to_not change(Micropost, :count)
      end

      it 'ログインページにリダイレクトされること' do
        post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }

    before { @post = FactoryBot.create(:most_recent) }

    context '他のユーザの投稿を削除した場合' do
      before { log_in user }

      it '削除されないこと' do
        expect { delete micropost_path(@post) }.to_not change(Micropost, :count)
      end

      it 'ログインページにリダイレクトされること' do
        delete micropost_path(@post)
        expect(response).to redirect_to login_path
      end
    end

    context '未ログインの場合' do
      it '削除されないこと' do
        expect { delete micropost_path(@post) }.to_not change(Micropost, :count)
      end

      it 'ログインページにリダイレクトされること' do
        delete micropost_path(@post)
        expect(response).to redirect_to login_path
      end
    end
  end
end
