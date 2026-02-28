require "test_helper"

class Api::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Superheroes")
    @item = @category.items.create!(name: "Spider-Man", ranking: 1500)
    @item2 = @category.items.create!(name: "Batman", ranking: 1400)
  end

  test "GET index returns categories as JSON" do
    get "/api/v1/categories"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert_equal 1, json["data"].length
    assert_equal "Superheroes", json["data"][0]["name"]
  end

  test "GET show returns category with items as JSON" do
    get "/api/v1/categories/#{@category.id}"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert_equal "Superheroes", json["data"]["name"]
    assert_equal 2, json["data"]["items"].length
  end

  test "GET show returns 404 for non-existent category" do
    get "/api/v1/categories/99999"
    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert_equal "not_found", json["error"]
  end

  test "POST create creates category" do
    post "/api/v1/categories",
      params: { category: { name: "Movies" } },
      as: :json

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert_equal "Movies", json["data"]["name"]
  end

  test "POST create with invalid data returns error" do
    post "/api/v1/categories",
      params: { category: { name: "" } },
      as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "PATCH update updates category" do
    patch "/api/v1/categories/#{@category.id}",
      params: { category: { name: "Updated" } },
      as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Updated", json["data"]["name"]
  end

  test "DELETE destroys category" do
    assert_difference "Category.count", -1 do
      delete "/api/v1/categories/#{@category.id}"
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json["success"]
  end

  test "GET compare returns two random items" do
    get "/api/v1/categories/#{@category.id}/compare"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert json["data"]["item1"]
    assert json["data"]["item2"]
  end

  test "GET compare returns error with less than 2 items" do
    @item2.destroy
    get "/api/v1/categories/#{@category.id}/compare"
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "not_enough_items", json["error"]
  end

  test "POST vote updates rankings" do
    original_winner = @item.ranking
    original_loser = @item2.ranking

    post "/api/v1/categories/#{@category.id}/vote",
      params: { winner_id: @item.id, loser_id: @item2.id },
      as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert_equal "Vote recorded!", json["message"]

    @item.reload
    @item2.reload

    assert @item.ranking > original_winner, "Winner ranking should increase"
    assert @item2.ranking < original_loser, "Loser ranking should decrease"
  end

  test "GET tiers returns tier groupings" do
    @category.items.create!(name: "Superman", ranking: 1600)
    @category.items.create!(name: "Iron Man", ranking: 1300)
    @category.items.create!(name: "Wonder Woman", ranking: 1200)

    get "/api/v1/categories/#{@category.id}/tiers"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert json["data"]["S"]
    assert json["data"]["A"]
    assert json["data"]["B"]
    assert json["data"]["C"]
    assert json["data"]["D"]
  end

  test "GET tiers returns error with less than 5 items" do
    get "/api/v1/categories/#{@category.id}/tiers"
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "not_enough_items", json["error"]
  end

  test "GET charts returns chart data" do
    get "/api/v1/categories/#{@category.id}/charts"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["success"]
    assert json["data"]["max_rank"]
    assert json["data"]["min_rank"]
    assert json["data"]["items"]
  end

  test "GET charts returns error with no items" do
    @item.destroy
    @item2.destroy
    get "/api/v1/categories/#{@category.id}/charts"
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "no_items", json["error"]
  end

  test "POST bulk_import creates items" do
    assert_difference "Item.count", 3 do
      post "/api/v1/categories/#{@category.id}/bulk_import",
        params: { names: "Hulk\nThor\nLoki" },
        as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 3, json["data"]["count"]
  end
end
