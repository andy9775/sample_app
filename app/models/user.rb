class User < ApplicationRecord
  # self.email = self.email.downcase
  # self.email = email.downcase
  before_save { email.downcase! }
  attr_accessor :remember_token
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 225 },
                    format: { with:
                      /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password # class methods
  validates :password, presence: true, length: { minimum: 6 }

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  # forget a user
  def forget
    update_attribute :remember_digest, nil
  end

  # Returns true if the given token matches the digest
  # Uses the users remember_digest to compare against the provided
  # remember_token to determine if they are the same thing
  def authenticated?(remember_token)
    # if the remember digest is not set (e.g. we logout of one browser which
    # sets it to nil see forget method above) then we know that the user is not
    # authenticated
    return false if remember_digest.nil?
    # remember_digest refers to self.remember_digest - the DB column
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # class methods
  class << self
    # Returns that hash digest of the given string
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # returns a randomly generated token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
end
