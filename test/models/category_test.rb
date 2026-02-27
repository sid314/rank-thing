require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "name must be present" do
    category = Category.new(name: "")
    assert_not category.valid?
  end

  test "valid category is saved" do
    category = Category.new(name: "Comics #{Time.now.to_i}")
    assert category.save
  end

  test "has many items" do
    category = Category.create!(name: "Test Category")
    item = category.items.create!(name: "Spider-Man", ranking: 1200)
    assert category.items.include?(item)
  end

  test "dependent destroy" do
    category = Category.create!(name: "Test Destroy")
    category.items.create!(name: "Item 1", ranking: 1200)
    category.items.create!(name: "Item 2", ranking: 1000)

    assert_difference "Item.count", -2 do
      category.destroy
    end
  end
end
