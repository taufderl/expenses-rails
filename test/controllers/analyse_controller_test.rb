require 'test_helper'

class AnalyseControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
