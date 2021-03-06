class User < ActiveRecord::Base
  rolify

  # Associations
  belongs_to :state
  belongs_to :district
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar, :styles => {:thumb => "75x75#" },
                    :default_url => "user_missing.png"
  has_many :authentication, :dependent => :delete_all
  has_many :needs, :dependent => :delete_all
  has_many :notifications, :dependent => :delete_all

  # Scopes
  has_many :posts
  scope :email_notification_enabled, where('can_send_email = ?', true)
  scope :sms_notification_enabled, where('can_send_sms = ?', true)
  scope :phone_not_empty, where.not('phone_no' => nil)
  scope :receive_newsletter, where('can_receive_newsletter = ?', true)
  has_one :participant

  # Validations
  validates_attachment :avatar,
                       :content_type => { :content_type => ["image/jpeg","image/jpg", "image/gif", "image/png"] },
                       :size => { :in => 0..200.kilobytes }

  has_many :activities

  # holds the organizations to which i am connected + added by me. 
  has_and_belongs_to_many :organizations 
  
  # holds the organizations those are just created by the pearticular . 
  has_many :my_organizations, class_name: 'Organization', foreign_key: 'user_id'
  scope :email_notification_enabled, -> { where(can_send_email: true) }
  scope :sms_notification_enabled, -> { where(can_send_sms: true) }
  scope :phone_not_empty, -> { where.not(phone_no: nil) }
  scope :with_blood, ->(type) { where(users: {blood_group: type}) }
  scope :donors, -> { where(is_donor: true) }


  #validates_attachment :avatar,
  #                     :content_type => { :content_type => ["image/jpeg","image/jpg", "image/gif", "image/png"] },
  #                     :size => { :in => 0..200.kilobytes }

  validates :name,:email,:phone_no, presence: true
  validates :terms_of_service, acceptance: { accept: '1' }
  validates :phone_no, length: { is: 10 }, numericality: true
  validates :blood_group , presence: true, unless: :skip_blood_group_validation
  validates :state_id , presence: true, unless: :skip_state_id_validation
  validates :district_id , presence: true, unless: :skip_district_id_validation

  attr_accessor :skip_blood_group_validation, :skip_state_id_validation, :skip_district_id_validation

  # Constants
  BLOOD_GROUPS = %w(A1+ A1- A2+ A2- B+ B- A1B+ A1B- A2B+ A2B- AB+ AB- O+ O- A+ A-)

  def self.search(params)
    users = User.where nil

    params.each do |k, v|
      users = users.where(k => v) if v.present?
    end

    users
  end

  delegate :name, to: :state, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true


  def apply_omniauth(auth)
    # In previous omniauth, 'user_info' was used in place of 'raw_info'
    self.email    = auth['info']['email']
    self.name     = auth['info']['name']
    self.avatar_url= auth['info']['image']
    self.phone_no    = auth['info']['phone']
    self.phone_no_visibility = true
    self.is_donor = true
    require 'bcrypt'
    pepper = nil
    cost = 10
    encrypted_password = ::BCrypt::Password.create("#{Time.now.to_s}#{pepper}", :cost => cost).to_s
    self.encrypted_password = encrypted_password
    # Again, saving token is optional. If you haven't created the column in authentications table, this will fail
    authentication.build(:provider => auth['provider'], :uid => auth['uid'], :token => auth['credentials']['token'])
  end


  # Description: Following method will return current users Organization list.
  def get_my_organizations
    @list ||= organizations
  end

  def get_activities
    activities.order(created_at: :desc)
  end

  def created_organization(organization)
    self.activities << Activity.build_activity(organization.name)
  end

  def updated_organization(organization)
    self.activities << Activity.create_activity(organization.name)
  end

  # Following method will dump dummy users to table.
  #use it just for testing purpose in development environment.
  def self.load!(count = 1)

    count.times do
      User.create! user_params
    end

  end

  # Following method will prepare dummy params for creating users.
  def self.user_params
    phone_number = "9668" + (100000..999999).to_a.sample.to_s
    common_password = 'blood_bank'
    state = State.all.sample
    district = state.districts.sample
    district_id = state.districts.sample
    blood_group = BLOOD_GROUPS.sample
    name = Faker::Name.first_name
    email = Faker::Internet.email

    user_params = {
      name: name,
      email: email,
      password: common_password,
      password_confirmation: common_password,
      state_id: state.id,
      blood_group: blood_group,
      district_id: district.id,
      phone_no: phone_number,
      is_donor: true
    }
  end

end
