class Expense < ActiveRecord::Base
  belongs_to :category
  belongs_to :subcategory
  belongs_to :user
  has_and_belongs_to_many :tags
  validates :to, presence: true
  validates :category, presence: true
  validates_uniqueness_of :md5, allow_blank: true, scope: :user_id
  default_scope { where( user_id: User.logged_in )}
  
  def tag_list
    self.tags.map {|s| s.name}.join(", ")
  end
  
  def tag_list=(new_value)
    tag_names = new_value.split(/,\s+/)
    # TODO FIXME: tag must fill user reference!!
    self.tags = tag_names.map { |name| Tag.where(name: name).first or Tag.create(name: name)} 
  end
end
