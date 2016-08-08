class District < ActiveRecord::Base
  belongs_to :state
  has_many :users
  has_many :organizations
  has_many :colleges

  scope :name_list, -> { pluck(:name, :id) }

  
end
