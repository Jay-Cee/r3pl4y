require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = games(:one)
  end

  test "should show game" do
    get :show, id: @game.to_param
    assert_response :success
  end
end
