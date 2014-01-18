# Sku Documentation
#
# The Sku table manages all the product variations. The Sku column value is automatically generated by the product SKU being combined with
# the attribute_value field. Each attribute value is unique within its parent product, and each SKU is unique globally. Both 
# the accessory and product tables utitlise the Sku table in order to create an easy and scalable database. 

# == Schema Information
#
# Table name: skus
#
#  id                         :integer          not null, primary key
#  sku                        :string(255)      
#  length                     :decimal          precision(8), scale(2) 
#  weight                     :decimal          precision(8), scale(2) 
#  thickness                  :decimal          precision(8), scale(2) 
#  attribute_value            :string(255) 
#  attribute_type_id          :integer 
#  stock                      :integer 
#  stock_warning_level        :integer 
#  cost_value                 :decimal          precision(8), scale(2) 
#  price                      :decimal          precision(8), scale(2) 
#  product_id                 :integer 
#  accessory_id               :integer          
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Sku < ActiveRecord::Base
  
  attr_accessible :cost_value, :price, :sku, :stock, :stock_warning_level, :length, 
  :weight, :thickness, :product_id, :attribute_value, :attribute_type_id, :accessory_id
  
  validates :price, :cost_value, :stock, :length, 
  :weight, :thickness, :stock_warning_level, 
  :attribute_value, :attribute_type_id,             :presence => true
  validates :price, :cost_value,                    :format => { :with => /^(\$)?(\d+)(\.|,)?\d{0,2}?$/ }
  validates :length, :weight, :thickness,           :numericality => { :greater_than_or_equal_to => 0 }
  validates :stock, :stock_warning_level,           :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }
  validate :check_stock_values,                     :on => :create
  validates :sku,                                   :uniqueness => true
  validates :attribute_value,                       :uniqueness => { :scope => :product_id }

  belongs_to :product
  belongs_to :accessory
  belongs_to :attribute_type
  has_many :cart_items,                             :dependent => :restrict
  has_many :carts,                                  :through => :cart_items, :dependent => :restrict
  has_many :order_items,                            :dependent => :restrict
  has_many :orders,                                 :through => :order_items, :dependent => :restrict
  has_many :notifications,                          as: :notifiable, :dependent => :delete_all

  before_destroy :validate_association_count

  def check_stock_values
    if self.stock && self.stock_warning_level && self.stock <= self.stock_warning_level
      errors.add(:sku, "stock warning level value must not be below your stock count.")
      return false
    end
  end

  private

  def validate_association_count
    product = Product.find(self.product.id)
    if product.skus.count < 2
      product.errors[:base] << "You must have at least one SKU per product."
      return false
    end
  end 

end
