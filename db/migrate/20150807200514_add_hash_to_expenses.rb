class AddHashToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :md5, :string
  end
end
