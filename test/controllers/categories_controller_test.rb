require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Superheroes")
    @item = @category.items.create!(name: "Spider-Man", ranking: 1500)
    @item2 = @category.items.create!(name: "Batman", ranking: 1400)
  end

  test "GET index shows categories" do
    get categories_path
    assert_response :success
  end

  test "GET new shows form" do
    get new_category_path
    assert_response :success
  end

  test "POST create with valid data redirects to category" do
    post categories_path, params: { category: { name: "Movies #{Time.now.to_i}" } }
    assert_redirected_to category_path(Category.last)
  end

  test "POST create with invalid data re-renders form" do
    post categories_path, params: { category: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "GET show displays category and items" do
    get category_path(@category)
    assert_response :success
    assert_select "h3", /Spider-Man/
  end

  test "GET edit shows form" do
    get edit_category_path(@category)
    assert_response :success
  end

  test "PATCH update with valid data redirects" do
    patch category_path(@category), params: { category: { name: "Updated Name" } }
    assert_redirected_to category_path(@category)
    @category.reload
    assert_equal "Updated Name", @category.name
  end

  test "DELETE destroys category" do
    assert_difference "Category.count", -1 do
      delete category_path(@category)
    end
    assert_redirected_to categories_path
  end

  test "GET compare shows two items" do
    get compare_category_path(@category)
    assert_response :success
  end

  test "GET compare redirects if fewer than 2 items" do
    @item2.destroy
    get compare_category_path(@category)
    assert_redirected_to categories_path
  end

  test "POST vote updates rankings" do
    original_winner = @item.ranking
    original_loser = @item2.ranking

    post vote_category_path(@category), params: { winner_id: @item.id, loser_id: @item2.id }

    @item.reload
    @item2.reload

    assert @item.ranking > original_winner, "Winner ranking should increase"
  end

  test "GET tiers shows tier list with 5+ items" do
    @category.items.create!(name: "Superman", ranking: 1600)
    @category.items.create!(name: "Iron Man", ranking: 1300)
    @category.items.create!(name: "Wonder Woman", ranking: 1200)

    get tiers_category_path(@category)
    assert_response :success
  end

  test "GET tiers redirects with fewer than 5 items" do
    get tiers_category_path(@category)
    assert_redirected_to category_path(@category)
  end

  test "GET charts shows bar chart" do
    get charts_category_path(@category)
    assert_response :success
  end

  test "GET charts redirects with no items" do
    @item.destroy
    @item2.destroy
    get charts_category_path(@category)
    assert_redirected_to category_path(@category)
  end

  test "GET import shows form" do
    get import_category_path(@category)
    assert_response :success
  end

  test "POST bulk_import creates items" do
    assert_difference "Item.count", 3 do
      post bulk_import_category_path(@category), params: { names: "Hulk\nThor\nLoki" }
    end
    assert_redirected_to category_path(@category)
  end

  test "compare shows items in random order not sorted by ranking" do
    @category.items.create!(name: "High Rank", ranking: 2000)
    @category.items.create!(name: "Low Rank", ranking: 800)

    results = []
    5.times do
      get compare_category_path(@category)
      assert_response :success
      doc = Nokogiri::HTML(response.body)
      items = doc.css(".comic-panel h2").map(&:text)
      results << items
    end

    assert results.uniq.length > 1, "Compare should show different orderings"
  end

  test "bulk import with empty lines ignores them" do
    assert_difference "Item.count", 3 do
      post bulk_import_category_path(@category), params: { names: "Hulk\n\nThor\n  \nLoki" }
    end
  end

  test "compare shows items from same category only" do
    other_category = Category.create!(name: "Other")
    other_item = other_category.items.create!(name: "Other Item", ranking: 1500)

    get compare_category_path(@category)
    assert_response :success

    assert_no_match /Other Item/, response.body
  end
end
