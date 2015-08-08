class Subcategory < ActiveRecord::Base
  belongs_to :category
  has_many :expenses
  belongs_to :user
  validates :category, presence: true
  validates :name, presence: true
  validates :name, uniqueness: {scope: :category}
  default_scope { where( user_id: User.logged_in )}
end
