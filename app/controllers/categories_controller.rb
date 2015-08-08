class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!


  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.includes(:subcategories).order(:name)
    @subcategories = Subcategory.all
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    params[:view] = params[:view] || 'table'
    case params[:view]
    when 'chart'
      @months = Expense.where.where(category: @category).map {|e| e.date}.map{ |d| d.strftime("%Y-%m") }.uniq.sort()
      @expenses_series_per_subcategory = []
      @category.subcategories.each do |s|
        subcategory = {name: s.name, data: []}
        @months.each do |month|
          expenses = @category.expenses.where(subcategory: s).where("strftime('%Y-%m', date) = ?", month)
          subcategory[:data].append(expenses.map {|e| e.amount }.sum.to_f)
        end
        @expenses_series_per_subcategory.append subcategory
      end
      subcategory = {name: "No subcategory", data: []}
      @months.each do |month|
          expenses = @category.expenses.where(subcategory: nil).where("strftime('%Y-%m', date) = ?", month)
          subcategory[:data].append(expenses.map {|e| e.amount }.sum.to_f)
        end
        @expenses_series_per_subcategory.append subcategory
      render :show_chart
    when 'table'
      @q = Expense.where(category: @category).ransack(params[:q])
      @expenses = @q.result(distinct: true).includes(:category, :subcategory, :tags).order(:date)
      render :show_table
    end
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name, :subcategory_list)
    end
end
