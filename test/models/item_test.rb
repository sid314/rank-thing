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

  test "winner ranking increases after vote" do
    winner = @category.items.create!(name: "Winner", ranking: 1500)
    loser = @category.items.create!(name: "Loser", ranking: 1400)
    original = winner.ranking

    Item.update_rankings(winner, loser)
    winner.reload

    assert winner.ranking > original, "Winner ranking must increase"
  end

  test "loser ranking decreases after vote" do
    winner = @category.items.create!(name: "Winner", ranking: 1500)
    loser = @category.items.create!(name: "Loser", ranking: 1400)
    original = loser.ranking

    Item.update_rankings(winner, loser)
    loser.reload

    assert loser.ranking < original, "Loser ranking must decrease"
  end

  test "two items with same ranking - both change after vote" do
    winner = @category.items.create!(name: "Winner", ranking: 1500)
    loser = @category.items.create!(name: "Loser", ranking: 1500)

    Item.update_rankings(winner, loser)

    winner.reload
    loser.reload

    assert winner.ranking != 1500, "Winner ranking must change"
    assert loser.ranking != 1500, "Loser ranking must change"
    assert winner.ranking > loser.ranking, "Winner should still be higher"
  end

  test "upset victory - low ranked beats high ranked gets big boost" do
    underdog = @category.items.create!(name: "Underdog", ranking: 1000)
    favorite = @category.items.create!(name: "Favorite", ranking: 2000)
    original_underdog = underdog.ranking

    Item.update_rankings(underdog, favorite)
    underdog.reload

    assert underdog.ranking > original_underdog + 20, "Underdog should get big boost"
  end

  test "expected victory - high ranked beats low ranked gets small boost" do
    favorite = @category.items.create!(name: "Favorite", ranking: 2000)
    underdog = @category.items.create!(name: "Underdog", ranking: 1000)
    original_favorite = favorite.ranking

    Item.update_rankings(favorite, underdog)
    favorite.reload

    assert favorite.ranking > original_favorite, "Favorite ranking increases"
    assert favorite.ranking - original_favorite < 5, "Favorite gets small boost since win was expected"
  end
end
