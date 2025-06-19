require "test_helper"

class ExamControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get exam_index_url
    assert_response :success
  end

  test "should get show" do
    get exam_show_url
    assert_response :success
  end

  test "should get start" do
    get exam_start_url
    assert_response :success
  end

  test "should get answer" do
    get exam_answer_url
    assert_response :success
  end

  test "should get result" do
    get exam_result_url
    assert_response :success
  end

  test "should get history" do
    get exam_history_url
    assert_response :success
  end
end
