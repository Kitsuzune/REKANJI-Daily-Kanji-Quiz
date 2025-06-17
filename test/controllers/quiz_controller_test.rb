require "test_helper"

class QuizControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get quiz_index_url
    assert_response :success
  end

  test "should get practice" do
    get quiz_practice_url
    assert_response :success
  end

  test "should get single" do
    get quiz_single_url
    assert_response :success
  end

  test "should get mixed" do
    get quiz_mixed_url
    assert_response :success
  end
end
