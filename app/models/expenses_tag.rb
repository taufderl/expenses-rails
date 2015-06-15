class ExpensesTag < ActiveRecord::Base
  belongs_to :expense
  belongs_to :tag
end
