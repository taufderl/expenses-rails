class SubcategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subcategory, only: [:show]

  # GET /subcategories
  # GET /subcategories.json
  def index
    params.permit(:category_id)
    if params[:category_id]
      @subcategories = Subcategory.where(user: current_user).where(category_id: params[:category_id])
    else
      @subcategories = Subcategory.where(user: current_user)
    end
  end

  # GET /subcategories/1
  # GET /subcategories/1.json
  def show
    @q = Expense.where(user: current_user).where(category: @subcategory.category, subcategory: @subcategory).ransack(params[:q])
    @expenses = @q.result(distinct: true).includes(:category, :subcategory, :tags).order(:date)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subcategory
      @subcategory = Subcategory.where(user: current_user).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subcategory_params
      params.require(:subcategory).permit(:name, :category_id)
    end
end
