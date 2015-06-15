json.array!(@expenses) do |expense|
  json.extract! expense, :id, :to, :note, :category_id, :date
  json.url expense_url(expense, format: :json)
end
