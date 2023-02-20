require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  test "Going to /new gives us a new random grid to play with" do
    visit new_url
    assert test: "New game"
    assert_selector "li", count: 10
  end
  test "saying WHAT IS YOUR NAME? yields a grumpy response from the coach" do
    visit new_url
    fill_in "user_word", with: "JEUNESSE"
    click_on "Play!"

    assert_text "Sorry but JEUNESSE does not seem to be a valid English word!"
  end
end
