require "test_helper"

class BidsControllerTest < ActionDispatch::IntegrationTest
  test "should get accept" do
    get bids_accept_url
    assert_response :success
  end
end
