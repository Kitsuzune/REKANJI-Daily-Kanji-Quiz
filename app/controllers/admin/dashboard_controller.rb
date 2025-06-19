class Admin::DashboardController < ApplicationController
  before_action :require_superadmin
  
  def index
    @total_users = User.count
    @total_single_kanji = KanjiSingle.count
    @total_multiple_kanji = KanjiMultiple.count
    @recent_users = User.order(created_at: :desc).limit(5)
    @kanji_by_rate = {
      single: KanjiSingle.group(:rate).count,
      multiple: KanjiMultiple.group(:rate).count
    }
    
    # Quiz attempt statistics
    @quiz_stats = {
      total_attempts: QuizAttempt.count,
      total_correct: QuizAttempt.correct.count,
      attempts_by_level: QuizAttempt.group(:level).count,
      attempts_by_type: QuizAttempt.group(:quiz_type).count,
      daily_attempts: QuizAttempt.where(answered_at: 24.hours.ago..Time.current).count,
      weekly_attempts: QuizAttempt.where(answered_at: 1.week.ago..Time.current).count
    }
    
    # User activity
    @top_users = User.joins(:quiz_attempts)
                     .group('users.id', 'users.email')
                     .order('COUNT(quiz_attempts.id) DESC')
                     .limit(10)
                     .pluck('users.email', 'COUNT(quiz_attempts.id)')
  end
end
