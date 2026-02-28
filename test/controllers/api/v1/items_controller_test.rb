require "test_helper"

class Api::V1::ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Superheroes")
    @item = @category.items.create!(name: "Spider-Man", ranking: 1500)
  end

  test "GET show returns item as JSON" do
    get "/api/v1/items/#{@item.id}"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert_equal "Spider-Man", json["data"]["name"]
    assert_equal 1500, json["data"]["ranking"]
  end

  test "GET show returns 404 for non-existent item" do
    get "/api/v1/items/99999"
    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert_equal "not_found", json["error"]
  end

  test "POST create creates item" do
    post "/api/v1/categories/#{@category.id}/items",
      params: { item: { name: "Batman", ranking: 1400 } },
      as: :json

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert_equal "Batman", json["data"]["name"]
  end

  test "POST create with default ranking" do
    post "/api/v1/categories/#{@category.id}/items",
      params: { item: { name: "New Hero" } },
      as: :json

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 1200, json["data"]["ranking"]
  end

  test "PATCH update updates item" do
    patch "/api/v1/items/#{@item.id}",
      params: { item: { name: "Spider-Man Updated", ranking: 1600 } },
      as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Spider-Man Updated", json["data"]["name"]
    assert_equal 1600, json["data"]["ranking"]
  end

  test "DELETE destroys item" do
    assert_difference "Item.count", -1 do
      delete "/api/v1/items/#{@item.id}"
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json["success"]
  end
end
