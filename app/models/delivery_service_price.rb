# DeliveryServicePrice Documentation
#
# The delivery_service_price table contains a list of available delivery prices for a type of delivery service. 
# Each with a description and price and dimension parameters.

# == Schema Information
#
# Table name: delivery_service_prices
#
#  id                       :integer          not null, primary key
#  code                     :string(255)          
#  price                    :decimal          precision(8), scale(2)
#  description              :text          
#  min_weight               :decimal          precision(8), scale(2)
#  max_weight               :decimal          precision(8), scale(2)
#  min_length               :decimal          precision(8), scale(2)
#  max_length               :decimal          precision(8), scale(2)
#  min_thickness            :decimal          precision(8), scale(2)
#  max_thickness            :decimal          precision(8), scale(2)
#  delivery_service_id      :integer          not null
#  active                   :boolean          default(true)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
class DeliveryServicePrice < ActiveRecord::Base

  attr_accessible :code, :price, :description, :min_weight, :max_weight, :min_length, :max_length, 
  :min_thickness, :max_thickness, :active, :zone_ids, :delivery_service_id

  has_many :orders,                                                     foreign_key: :delivery_id, dependent: :restrict_with_exception
  belongs_to :delivery_service

  validates :code, :price, :min_weight, :max_weight,
  :min_length, :max_length, :min_thickness, :max_thickness,             presence: true
  validates :code,                                                      uniqueness: { scope: [:active, :delivery_service_id] }
  validates :description,                                               length: { maximum: 180, message: :too_long }
  validates :price,                                                     format: { with: /\A(\$)?(\d+)(\.|,)?\d{0,2}?\z/ }

  default_scope { order(price: :asc) }
  
  include ActiveScope
  # scope :find_collection,                               ->(cart, country) { joins(:tiereds, :countries).where(tiereds: { :tier_id => cart.order.tiers }, countries: { :name => country }).load }

end
