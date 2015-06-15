class AddAmountToExpense < ActiveRecord::Migration
  def change
    add_column :expenses, :amount, :decimal, precision: 10, scale: 2
  end
end
