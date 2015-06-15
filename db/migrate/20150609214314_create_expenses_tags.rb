class CreateExpensesTags < ActiveRecord::Migration
  def change
    create_table :expenses_tags do |t|
      t.references :expense, index: true, foreign_key: true
      t.references :tag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
