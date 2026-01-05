class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end
  def show
    @category = Category.find(params[:id])
    @items = @category.items.order(ranking: :desc)
  end
  def new
    @category = Category.new
  end
  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:notice] = "Category created successfully"
      redirect_to category_path(@category)
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit
    @category = Category.find(params[:id])
  end
  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      flash[:notice] = "Category updated successfully"
      redirect_to category_path(@category)
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    flash[:notice] = "Category deleted successfully"
    redirect_to categories_path
  end
def compare
  @category = Category.find(params[:id])
  @items = @category.items.sample(2).sort_by(&:ranking).reverse
  if @items.size < 2
      redirect_to categories_path, alert: "Not enough items to compare"
  end
end
def vote
  @category = Category.find(params[:id])
  winner = Item.find(params[:winner_id])
  loser = Item.find(params[:loser_id])
  Item.update_rankings(winner, loser)

  redirect_to compare_category_path(@category), notice: "Vote recorded!"
end
  def category_params
    params.require(:category).permit(:name)
  end
end
