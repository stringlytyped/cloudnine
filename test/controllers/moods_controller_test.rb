require 'test_helper'

class MoodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mood = moods(:one)
  end

  test "should get index" do
    get moods_url
    assert_response :success
  end

  test "should get new" do
    get new_mood_url
    assert_response :success
  end

  test "should create mood" do
    assert_difference('Mood.count') do
      post moods_url, params: { mood: { rating: @mood.rating, username: @mood.username, when: @mood.when } }
    end

    assert_redirected_to mood_url(Mood.last)
  end

  test "should show mood" do
    get mood_url(@mood)
    assert_response :success
  end

  test "should get edit" do
    get edit_mood_url(@mood)
    assert_response :success
  end

  test "should update mood" do
    patch mood_url(@mood), params: { mood: { rating: @mood.rating, username: @mood.username, when: @mood.when } }
    assert_redirected_to mood_url(@mood)
  end

  test "should destroy mood" do
    assert_difference('Mood.count', -1) do
      delete mood_url(@mood)
    end

    assert_redirected_to moods_url
  end
end
