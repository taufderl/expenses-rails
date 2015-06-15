class AddSourceToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :source, :string
  end
end
