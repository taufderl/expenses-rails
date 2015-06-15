class DashboardController < ApplicationController
  def index
    params[:view] = params[:view] || 'pie'
    @categories = Category.select("category_id, name, sum(expenses.amount) as total_amount, count(*) as expense_count")
      .joins(:expenses).where("strftime('%Y-%m', date) = ?", Date.today.strftime('%Y-%m'))
      .group('expenses.category_id').order('total_amount DESC')
    
    @averages = {}
    @categories.each do |c|
      @averages[c.category_id] = Category.find(c.category_id).average
    end
    
    @total_amount = @categories.map{ |c| c.total_amount}.sum
    @pie_data = @categories.map {|c| [c.name, c.total_amount]}
  end
end
