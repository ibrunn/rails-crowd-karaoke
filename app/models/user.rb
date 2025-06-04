class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sessions, dependent: :destroy

  validates :name, presence: true,
            length: { maximum: 20 },
            format: { with: /\A[a-zA-Z0-9\s]+\z/,
            message: "only letters, numbers, and spaces allowed" }
  validates :email, uniqueness: { case_sensitive: false }

end
