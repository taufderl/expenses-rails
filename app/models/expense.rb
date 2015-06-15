class Expense < ActiveRecord::Base
  belongs_to :category
  belongs_to :subcategory
  has_and_belongs_to_many :tags
  validates :to, presence: true
  validates :category, presence: true
  
  def tag_list
    self.tags.map {|s| s.name}.join(", ")
  end
  
  def tag_list=(new_value)
    tag_names = new_value.split(/,\s+/)
    self.tags = tag_names.map { |name| Tag.where(name: name).first or Tag.create(name: name)} 
  end
end
