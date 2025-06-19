class HomeController < ApplicationController
  def index
    if user_signed_in?
      @total_single_kanjis = {
        'N5' => KanjiSingle.by_rate('N5').count,
        'N4' => KanjiSingle.by_rate('N4').count,
        'N3' => KanjiSingle.by_rate('N3').count
      }
      
      @total_multiple_kanjis = {
        'N5' => KanjiMultiple.by_rate('N5').count,
        'N4' => KanjiMultiple.by_rate('N4').count,
        'N3' => KanjiMultiple.by_rate('N3').count
      }
      
      # User progress statistics
      @user_stats = {
        total_single: @total_single_kanjis.values.sum,
        total_multiple: @total_multiple_kanjis.values.sum,
        attempts: current_user.total_attempts,
        correct: current_user.total_correct,
        accuracy: current_user.overall_accuracy
      }
      
      # Level-based progress untuk history attempts
      @level_progress = {}
      %w[N5 N4 N3].each do |level|
        @level_progress[level] = {
          single: current_user.progress_for_kanji_type('KanjiSingle', level),
          multiple: current_user.progress_for_kanji_type('KanjiMultiple', level),
          accuracy: current_user.accuracy_for_level(level)
        }
      end
      
      # Recent quiz attempts for history
      @recent_attempts = current_user.quiz_attempts
                                    .recent
                                    .limit(10)
                                    .includes(:user)
      
      # Correct and incorrect attempts by level
      @progress_for_level = {}
      %w[N5 N4 N3].each do |level|
        correct_count = current_user.quiz_attempts.by_level(level).correct.count
        total_count = current_user.quiz_attempts.by_level(level).count
        
        @progress_for_level[level] = {
          correct: correct_count,
          total: total_count,
          accuracy: total_count > 0 ? (correct_count.to_f / total_count * 100).round(1) : 0
        }
      end
    end
  end
end
