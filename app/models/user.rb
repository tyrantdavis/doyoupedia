
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # Delete wikis owned by user when user is deleted.
  has_many :wikis, dependent: :destroy

  before_save { self.role ||= :standard }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :authentication_keys => {email: true, login: false}

  enum role: [:standard, :premium, :admin]

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  validates :username, presence: true, length: {maximum: 255}, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9]*\z/, :multiline => true, message: "may only contain letters and numbers." }

  # validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  # backup validation providing extra security
  # validate :validate_username
  #
  # def validate_username
  #   if User.where(email: username).exists?
  #     errors.add(:username, :invalid)
  #   end
  # end

  # creates a virtual login attribute
#   def login=(login)
#     @login = login
#   end
#
#   def login
#     @login || self.username || self.email
#   end

# Virtual attribute for authenticating by either username or email
# This is in addition to a real persisted field like 'username'
attr_accessor :login
end
