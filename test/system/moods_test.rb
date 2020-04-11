require "application_system_test_case"

class MoodsTest < ApplicationSystemTestCase
  setup do
    @mood = moods(:one)
  end

  test "visiting the index" do
    visit moods_url
    assert_selector "h1", text: "Moods"
  end

  test "creating a Mood" do
    visit moods_url
    click_on "New Mood"

    fill_in "Rating", with: @mood.rating
    fill_in "Username", with: @mood.username
    fill_in "When", with: @mood.when
    click_on "Create Mood"

    assert_text "Mood was successfully created"
    click_on "Back"
  end

  test "updating a Mood" do
    visit moods_url
    click_on "Edit", match: :first

    fill_in "Rating", with: @mood.rating
    fill_in "Username", with: @mood.username
    fill_in "When", with: @mood.when
    click_on "Update Mood"

    assert_text "Mood was successfully updated"
    click_on "Back"
  end

  test "destroying a Mood" do
    visit moods_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Mood was successfully destroyed"
  end
end
