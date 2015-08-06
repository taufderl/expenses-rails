class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_expense, only: [:show, :edit, :update, :destroy]

  # GET /expenses
  # GET /expenses.json
  def index
    @q = Expense.where(user: current_user).ransack(params[:q])
    @expenses = @q.result(distinct: true).includes(:category, :subcategory, :tags).order(:date)
  end

  # GET /expenses/1
  # GET /expenses/1.json
  def show
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses
  # POST /expenses.json
  def create
    @expense = Expense.new(expense_params.merge({user: current_user}))
    @expense.source = :webapp
    respond_to do |format|
      if @expense.save
        format.html { redirect_to :back, notice: 'Expense was successfully created.' }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1
  # PATCH/PUT /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to :back, notice: 'Expense was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { redirect :back}
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1
  # DELETE /expenses/1.json
  def destroy
    @expense.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Expense was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def duplicates
    @set1 = Expense.where(user: current_user).includes(:tags, :category, :subcategory).all
    @set2 = Expense.where(user: current_user).includes(:tags, :category, :subcategory).all
    
    @duplicates = []
    @set1.each_with_index do |e1, index1|
      @set2.each_with_index do |e2, index2|
        if index1 < index2
          if e1.date == e2.date and e1.amount == e2.amount
            if e1.source == e2.source
              if e1.to == e2.to and e1.note == e2.note
                @duplicates.append([e1,e2])
              end
            else
              @duplicates.append([e1,e2])
            end
          end
        end
      end
    end
  end
  
  def merge
    @e1 = Expense.where(user: current_user).find_by_id params[:e1]
    @e2 = Expense.where(user: current_user).find_by_id params[:e2]
    if not @e1 and @e2
      redirect_to :expenses_duplicates, notice: 'One of the selected expenses does not exist anymore.'
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.where(user: current_user).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_params
      params.require(:expense).permit(:amount, :to, :note, :category_id, :subcategory_id, :date, :tag_list)
    end
end
