class User < ApplicationRecord
  # データベースに保存する前に小文字にする
  before_save { email.downcase! }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :name, presence: true, length: { maximum: 50 }
  validates :email,
            presence: true,
            length: {
              maximum: 255,
            },
            format: {
              with: VALID_EMAIL_REGEX,
            },
            uniqueness: {
              # 大文字小文字関係なく一意性を保つ
              case_sensitive: false,
            }
  validates :password, presence: true, length: { minimum: 6 }
  has_secure_password
end
