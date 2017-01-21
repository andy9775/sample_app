class User < ApplicationRecord
  has_many :microposts, dependent: :destroy # delete posts on user delete
  has_many :active_relationships, class_name:  'Relationship',
                                  foreign_key: 'follower_id',
                                  dependent:   :destroy
  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  
  # ===============
  # source: :follower can be omitted as rails singularizes :followers to
  # :follower and looks for 'follower_id' in the relationships table
  has_many :followers, through: :passive_relationships, source: :follower
  # ===============

  attr_accessor :remember_token, :activation_token, :reset_token
  # self.email = self.email.downcase
  # self.email = email.downcase
  before_save { email.downcase! }
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 225 },
                    format: { with:
                      /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }

  # has internal check for empty password on signup when no password exists
  has_secure_password # class methods

  validates :password,
            presence: true,
            length: { minimum: 6 },
            allow_nil: true # when editing - allow for empty passwords

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
  def authenticated?(attribute, token)
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # activates an account
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # sends an activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # create the password reset digest
  def create_reset_digest
    self.reset_token = User.new_token
    # calling update individually doesn't call validations not does
    # update_columns
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  # send the password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # determine if the password reset link was sent earlier than 2 hours ago
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    Micropost.where 'user_id = ?', id # self.id
  end

  # follow another user
  def follow(other_user)
    following << other_user
  end

  # unfollow another user
  def unfollow(other_user)
    following.delete other_user
  end

  # returns true if the current user is following the other user
  def following?(other_user)
    following.include? other_user
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

  private

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
