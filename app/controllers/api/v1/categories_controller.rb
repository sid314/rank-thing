class Api::V1::CategoriesController < ApiController
  before_action :json_request!, except: [:index, :show, :compare, :tiers, :charts, :destroy]

  def index
    categories = Category.all.order(created_at: :desc)
    render_success(
      data: categories.map { |c| category_json(c) }
    )
  end

  def show
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    render_success(
      data: category_json(category, include_items: true)
    )
  end

  def create
    category = Category.new(category_params)
    if category.save
      render_success(
        data: category_json(category),
        message: "Category created successfully",
        status: :created
      )
    else
      render_error(category.errors.full_messages.join(", "), error_type: "validation_error")
    end
  end

  def update
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    if category.update(category_params)
      render_success(
        data: category_json(category),
        message: "Category updated successfully"
      )
    else
      render_error(category.errors.full_messages.join(", "), error_type: "validation_error")
    end
  end

  def destroy
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    category.destroy
    render_success(message: "Category deleted successfully")
  end

  def compare
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    items = category.items.sample(2).shuffle
    if items.size < 2
      return render_error(
        "Need at least 2 items to compare",
        error_type: "not_enough_items",
        status: :bad_request
      )
    end

    render_success(
      data: {
        item1: { id: items[0].id, name: items[0].name },
        item2: { id: items[1].id, name: items[1].name }
      }
    )
  end

  def vote
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    winner_id = params[:winner_id]
    loser_id = params[:loser_id]

    if winner_id.blank? || loser_id.blank?
      return render_error(
        "Winner and loser are required",
        error_type: "validation_error",
        status: :bad_request
      )
    end

    winner = category.items.find_by(id: winner_id)
    loser = category.items.find_by(id: loser_id)

    unless winner && loser
      return render_error(
        "Winner or loser not found in this category",
        error_type: "not_found",
        status: :not_found
      )
    end

    Item.update_rankings(winner, loser)
    winner.reload
    loser.reload

    render_success(
      data: {
        winner: { id: winner.id, name: winner.name, ranking: winner.ranking },
        loser: { id: loser.id, name: loser.name, ranking: loser.ranking }
      },
      message: "Vote recorded!"
    )
  end

  def tiers
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    items = category.items.order(ranking: :desc)

    if items.count < 5
      return render_error(
        "Need at least 5 items for tier list",
        error_type: "not_enough_items",
        status: :bad_request
      )
    end

    rankings = items.pluck(:ranking)
    max_rank = rankings.max
    min_rank = rankings.min
    range = max_rank - min_rank
    tier_size = range / 5.0

    tiers = {
      "S" => items.select { |i| i.ranking >= max_rank - tier_size },
      "A" => items.select { |i| i.ranking >= max_rank - tier_size * 2 && i.ranking < max_rank - tier_size },
      "B" => items.select { |i| i.ranking >= max_rank - tier_size * 3 && i.ranking < max_rank - tier_size * 2 },
      "C" => items.select { |i| i.ranking >= max_rank - tier_size * 4 && i.ranking < max_rank - tier_size * 3 },
      "D" => items.select { |i| i.ranking < max_rank - tier_size * 4 }
    }

    render_success(
      data: tiers.transform_values { |items| items.map { |i| { id: i.id, name: i.name, ranking: i.ranking } } }
    )
  end

  def charts
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    items = category.items.order(ranking: :desc)

    if items.empty?
      return render_error(
        "No items to chart",
        error_type: "no_items",
        status: :bad_request
      )
    end

    max_rank = items.maximum(:ranking)
    min_rank = items.minimum(:ranking)

    items_data = items.map do |item|
      bar_width = if max_rank == min_rank
        50
      else
        ((item.ranking - min_rank) / (max_rank - min_rank) * 100).round
      end
      { id: item.id, name: item.name, ranking: item.ranking, bar_width: bar_width }
    end

    render_success(
      data: {
        max_rank: max_rank,
        min_rank: min_rank,
        items: items_data
      }
    )
  end

  def bulk_import
    category = Category.find_by(id: params[:id])
    return render_error("Category not found", error_type: "not_found", status: :not_found) unless category

    names = params[:names].to_s.split("\n").map(&:strip).reject(&:empty?)
    return render_error("No items to import", error_type: "validation_error") if names.empty?

    items = []
    names.each do |name|
      item = category.items.create!(name: name, ranking: 1200)
      items << { id: item.id, name: item.name, ranking: item.ranking }
    end

    render_success(
      data: { count: items.length, items: items },
      message: "#{items.length} items imported successfully!"
    )
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def category_json(category, include_items: false)
    json = {
      id: category.id,
      name: category.name,
      item_count: category.items.count,
      created_at: category.created_at,
      updated_at: category.updated_at
    }
    if include_items
      json[:items] = category.items.order(ranking: :desc).map do |item|
        {
          id: item.id,
          name: item.name,
          ranking: item.ranking,
          created_at: item.created_at,
          updated_at: item.updated_at
        }
      end
    end
    json
  end
end
