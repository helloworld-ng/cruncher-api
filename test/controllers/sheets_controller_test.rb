require 'test_helper'

class SheetsControllerTest < ActionController::TestCase
  test "should get crunch" do
    get :crunch
    assert_response :success
  end

end
