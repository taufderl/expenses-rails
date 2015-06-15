class AnalyseController < ApplicationController
  def index
  end
  
  def overview
    if ['area', 'bar'].include? params[:view]
      @months = Expense.all.map {|e| e.date}.map{ |d| d.strftime("%Y-%m") }.uniq.sort()
      @categories = Category.all.to_a
      @expenses_series_per_category = []
      @debug = []
      @categories.each do |c|
        category = {}
        category[:name] = c.name
        category[:data] = []
        @months.each do |month|
          expenses = Expense.all.where(category: c).where("strftime('%Y-%m', date) = ?", month)
          @debug.append expenses.length
          category[:data].append(expenses.map {|e| e.amount }.sum.to_f)
        end
        @expenses_series_per_category.append category
      end
      if params[:view] == 'area'
        render :overview_area
      else
        render :overview_bar
      end
    elsif 'donut' == params[:view]
      @categories = Category.all.order(:name)
      @categories_names = @categories.map{ |c| c.name }
      @data = [] 
      @categories.each do |c|
        subcategories = c.subcategories.order(:name)
        subcategory_names = subcategories.map{|s| s.name}
                            .append "No subcategory"
        subcategory_data = subcategories.map{ |s| s.expenses.map{|e| e.amount}.sum.to_f }
                            .append c.expenses.where(subcategory: nil).map {|e| e.amount}.sum.to_f
        @data.append( 
          { y: c.expenses.map{|e| e.amount}.sum.to_f,
            drilldown: {
              name: c.name,
              subcategories: subcategory_names,
              data: subcategory_data
            }
          })
      end
      render :overview_donut
    end
  end

end
