class Category < ActiveRecord::Base
  attr_accessible :description, :name, :visible
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :products
  validates :name, :description, :presence => true
  validates :name, :uniqueness => true
end
