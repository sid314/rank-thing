require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Superheroes")
    @item = @category.items.create!(name: "Spider-Man", ranking: 1500)
  end

  test "GET show displays item" do
    get item_path(@item)
    assert_response :success
    assert_select "dd", /Spider-Man/
  end

  test "GET edit shows form" do
    get edit_item_path(@item)
    assert_response :success
  end

  test "PATCH update with valid data redirects" do
    patch item_path(@item), params: { item: { name: "Spider-Man Updated", ranking: 1600 } }
    assert_redirected_to item_path(@item)
    assert_equal "Item was successfully updated.", flash[:notice]
    @item.reload
    assert_equal "Spider-Man Updated", @item.name
  end

  test "DELETE destroys item and redirects to category" do
    assert_difference "Item.count", -1 do
      delete item_path(@item)
    end
    assert_redirected_to category_path(@category)
    assert_equal "Item was successfully destroyed.", flash[:notice]
  end
end
