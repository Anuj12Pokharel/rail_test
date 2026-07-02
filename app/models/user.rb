class User < ApplicationRecord
  has_secure_password

  has_many :contents, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def name
    "#{first_name} #{last_name}".strip
  end
end
