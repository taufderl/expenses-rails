class Subcategory < ActiveRecord::Base
  belongs_to :category
  has_many :expenses
  validates :category, presence: true
  validates :name, presence: true
  validates :name, uniqueness: {scope: :category}
end
