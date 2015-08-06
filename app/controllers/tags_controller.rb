class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.where(user: current_user)
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    params[:view] = params[:view] || 'table'
    case params[:view]
    when 'chart'
      @expenses = @tag.expenses
      @categories = Category.where(user: current_user).order(:name)
      @categories_names = @categories.map{ |c| c.name }
      @data = [] 
      @categories.each do |c|
        subcategories = c.subcategories.order(:name)
        subcategory_names = subcategories.map{|s| s.name}
                            .append "No subcategory"
        subcategory_data = subcategories.map{ |s| @expenses.where(category: c, subcategory: s).map{|e| e.amount}.sum.to_f }
                            .append @expenses.where(category: c,subcategory: nil).map {|e| e.amount}.sum.to_f
        @data.append( 
          { y: @expenses.where(category: c).map{|e| e.amount}.sum.to_f,
            drilldown: {
              name: c.name,
              subcategories: subcategory_names,
              data: subcategory_data
            }
          })
      end
      render :show_chart
    when 'table'
      @q = Expense.where(user: current_user).joins(:tags).where('tags.id' => @tag).ransack(params[:q])
      @expenses = @q.result(distinct: true).includes(:category, :subcategory, :tags).order(:date)
      render :show_table
    end
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params.merge({user: current_user}))

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to tags_url, notice: 'Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.where(user: current_user).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name)
    end
end
