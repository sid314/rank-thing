require "test_helper"

class EdgeCasesTest < ActionDispatch::IntegrationTest
  test "empty category shows no items message" do
    category = Category.create!(name: "Empty Category")
    get category_path(category)
    assert_response :success
    assert_match /no items/i, response.body.downcase
  end

  test "single item category - compare redirects" do
    category = Category.create!(name: "Single Item")
    category.items.create!(name: "Only One", ranking: 1200)

    get compare_category_path(category)
    assert_redirected_to categories_path
  end

  test "bulk import with only empty lines creates nothing" do
    category = Category.create!(name: "Test")

    assert_no_difference "Item.count" do
      post bulk_import_category_path(category), params: { names: "\n\n  \n" }
    end

    assert_redirected_to category_path(category)
  end
end
