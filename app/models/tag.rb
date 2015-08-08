class Tag < ActiveRecord::Base
  has_and_belongs_to_many :expenses
  belongs_to :user
  default_scope { where( user_id: User.logged_in )}
end
