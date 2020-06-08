require 'test_helper'

class StartPageControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get start_page_start_url
    assert_response :success
  end

end
