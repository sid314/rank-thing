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
  def category_params
  params.require(:category).permit(:name)
  end
end
