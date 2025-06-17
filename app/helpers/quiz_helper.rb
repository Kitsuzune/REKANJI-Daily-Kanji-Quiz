module QuizHelper
  def result_is_correct?(result)
    return false unless result
    # Handle both string and symbol keys
    is_correct = result[:is_correct] || result["is_correct"]
    return false unless is_correct
    [true, "true", 1, "1"].include?(is_correct)
  end
end
