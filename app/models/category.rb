class Category < ActiveRecord::Base
  has_many :expenses
  has_many :subcategories
  validates :name, presence: true, uniqueness: true
  
  def average
    monthly_sums = self.expenses.group_by{ |e| e.date.strftime("%Y-%m") }.map{|m,l| l.map{|e|e.amount}.sum.to_f }
    (monthly_sums.sum / monthly_sums.length)
  end  
  
  def subcategory_list
    self.subcategories.map {|s| s.name}.join(", ")
  end
  
  def subcategory_list=(new_value)
    subcategory_names = new_value.split(/,\s+/)
    self.subcategories = subcategory_names.map { |name| Subcategory.where(category: self, name: name).first or Subcategory.create(category: self, name: name)} 
  end
end
