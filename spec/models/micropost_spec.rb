require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:user) { FactoryBot.create(:user) }

  let(:micropost) { user.microposts.build(content: 'Lorem ipsum') }

  it '有効であること' do
    expect(micropost).to be_valid
  end

  it 'user_idがない場合は、無効であること' do
    micropost.user_id = nil
    expect(micropost).to_not be_valid
  end

  it '並び順は投稿の新しい順になっていること' do
    FactoryBot.send(:user_with_posts)
    expect(FactoryBot.create(:most_recent)).to eq Micropost.first
  end

  it '投稿したユーザが削除された場合、そのユーザのMicropostも削除されること' do
    post = FactoryBot.create(:most_recent)
    user = post.user
    expect { user.destroy }.to change(Micropost, :count).by -1
  end

  describe 'content' do
    it '空なら無効であること' do
      micropost.content = '    '
      expect(micropost).to_not be_valid
    end

    it '141文字以上なら無効であること' do
      micropost.content = 'a' * 141
      expect(micropost).to_not be_valid
    end
  end
end
