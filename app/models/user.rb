class User < ApplicationRecord
  validates_uniqueness_of :email
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :confirmable, :trackable

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  # Override password_required for Google-authenticated users

  def self.from_google(uid:, email:, full_name:, avatar_url:)
    return nil unless email =~ /.com\z/
    find_or_create_by(uid: uid) do |user|
      user.email = email
      user.full_name = full_name
      user.avatar_url = avatar_url
    end
  end
end