class AddSubcatecoryToExpenses < ActiveRecord::Migration
  def change
    add_reference :expenses, :subcategory, index: true, foreign_key: true
  end
end
