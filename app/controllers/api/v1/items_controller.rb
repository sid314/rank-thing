class Api::V1::ItemsController < ApiController
  before_action :json_request!, except: [:show, :destroy]

  def show
    item = Item.find_by(id: params[:id])
    return render_error("Item not found", error_type: "not_found", status: :not_found) unless item

    render_success(data: item_json(item))
  end

  def create
    category = Category.find_by(id: params[:category_id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    item = category.items.new(item_params)
    if item.save
      render_success(
        data: item_json(item),
        status: :created
      )
    else
      render_error(item.errors.full_messages.join(", "), error_type: "validation_error")
    end
  end

  def update
    item = Item.find_by(id: params[:id])
    return render_error("Item not found", error_type: "not_found", status: :not_found) unless item

    if item.update(item_params)
      render_success(
        data: item_json(item),
        message: "Item updated successfully"
      )
    else
      render_error(item.errors.full_messages.join(", "), error_type: "validation_error")
    end
  end

  def destroy
    item = Item.find_by(id: params[:id])
    return render_error("Item not found", error_type: "not_found", status: :not_found) unless item

    item.destroy
    render_success(message: "Item deleted successfully")
  end

  private

  def item_params
    params.require(:item).permit(:name, :ranking)
  end

  def item_json(item)
    {
      id: item.id,
      name: item.name,
      ranking: item.ranking,
      category_id: item.category_id,
      created_at: item.created_at,
      updated_at: item.updated_at
    }
  end
end
