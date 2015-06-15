class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.string :to
      t.string :note
      t.references :category, index: true, foreign_key: true
      t.date :date

      t.timestamps null: false
    end
  end
end
