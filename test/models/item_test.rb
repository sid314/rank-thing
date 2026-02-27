require "test_helper"

class ItemTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Test")
  end

  test "belongs to category" do
    item = @category.items.create!(name: "Spider-Man", ranking: 1200)
    assert_equal @category, item.category
  end

  test "valid item is saved" do
    item = @category.items.new(name: "Batman", ranking: 1500)
    assert item.save
  end

  test "update_rankings changes rankings" do
    winner = @category.items.create!(name: "Winner", ranking: 1500)
    loser = @category.items.create!(name: "Loser", ranking: 1400)

    Item.update_rankings(winner, loser)

    winner.reload
    loser.reload

    assert winner.ranking > 1500, "Winner ranking should increase"
    assert loser.ranking <= 1400, "Loser ranking should not increase"
  end

  test "default ranking is 1200" do
    item = @category.items.create!(name: "Default")
    assert_equal 1200, item.ranking
  end
end
