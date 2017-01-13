class User < ApplicationRecord
  # self.email = self.email.downcase
  # self.email = email.downcase
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 225 },
                    format: { with:
                      /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password # class methods
  validates :password, presence: true, length: { minimum: 6 }
end
