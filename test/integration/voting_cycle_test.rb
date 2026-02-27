require "test_helper"

class VotingCycleTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Superheroes")
    @spider_man = @category.items.create!(name: "Spider-Man", ranking: 1500)
    @batman = @category.items.create!(name: "Batman", ranking: 1400)
    @superman = @category.items.create!(name: "Superman", ranking: 1600)
  end

  test "full voting cycle - vote changes rankings and compare continues" do
    spider_original = @spider_man.ranking
    batman_original = @batman.ranking

    get compare_category_path(@category)
    assert_response :success

    post vote_category_path(@category), params: { winner_id: @spider_man.id, loser_id: @batman.id }
    assert_redirected_to compare_category_path(@category)

    @spider_man.reload
    @batman.reload

    assert @spider_man.ranking > spider_original, "Winner ranking should increase"
    assert @batman.ranking < batman_original, "Loser ranking should decrease"

    get compare_category_path(@category)
    assert_response :success
  end

  test "tier list groups items correctly by ranking" do
    @category.items.create!(name: "Iron Man", ranking: 1300)
    @category.items.create!(name: "Wonder Woman", ranking: 1200)

    get tiers_category_path(@category)
    assert_response :success

    assert_match /S/, response.body
    assert_match /A/, response.body
    assert_match /B/, response.body
  end

  test "charts displays all items with bars" do
    get charts_category_path(@category)
    assert_response :success

    assert_match /Spider-Man/, response.body
    assert_match /Batman/, response.body
    assert_match /Superman/, response.body
  end

  test "bulk import then compare works" do
    post bulk_import_category_path(@category), params: { names: "Hulk\nThor\nWanda" }
    assert_redirected_to category_path(@category)

    @category.reload
    assert_equal 6, @category.items.count

    get compare_category_path(@category)
    assert_response :success
  end
end
