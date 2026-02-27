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
  @items = @category.items.sample(2).shuffle
  if @items.size < 2
      redirect_to categories_path, alert: "Not enough items to compare"
  end
end
def tiers
  @category = Category.find(params[:id])
  @items = @category.items.order(ranking: :desc)

  return redirect_to category_path(@category), alert: "Need at least 5 items for tier list" if @items.count < 5

  rankings = @items.pluck(:ranking)
  max_rank = rankings.max
  min_rank = rankings.min
  range = max_rank - min_rank

  tier_size = range / 5.0

  @tiers = {
    "S" => @items.select { |i| i.ranking >= max_rank - tier_size },
    "A" => @items.select { |i| i.ranking >= max_rank - tier_size * 2 && i.ranking < max_rank - tier_size },
    "B" => @items.select { |i| i.ranking >= max_rank - tier_size * 3 && i.ranking < max_rank - tier_size * 2 },
    "C" => @items.select { |i| i.ranking >= max_rank - tier_size * 4 && i.ranking < max_rank - tier_size * 3 },
    "D" => @items.select { |i| i.ranking < max_rank - tier_size * 4 }
  }
end
def charts
  @category = Category.find(params[:id])
  @items = @category.items.order(ranking: :desc)

  return redirect_to category_path(@category), alert: "No items to chart" if @items.empty?

  @max_rank = @items.maximum(:ranking)
  @min_rank = @items.minimum(:ranking)
end
def vote
  @category = Category.find(params[:id])
  winner = Item.find(params[:winner_id])
  loser = Item.find(params[:loser_id])
  Item.update_rankings(winner, loser)

  redirect_to compare_category_path(@category), notice: "Vote recorded!"
end
def import
  @category = Category.find(params[:id])
end
def bulk_import
  @category = Category.find(params[:id])
  names = params[:names].split("\n").map(&:strip).reject(&:empty?)

  count = 0
  names.each do |name|
    @category.items.create!(name: name, ranking: 1200)
    count += 1
  end

  flash[:notice] = "#{count} items imported successfully!"
  redirect_to category_path(@category)
end
  def category_params
    params.require(:category).permit(:name)
  end
end
