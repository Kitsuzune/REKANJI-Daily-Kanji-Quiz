class LearnController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @level = params[:level] || 'N5'
    redirect_to learn_index_path(level: 'N5') unless %w[N5 N4 N3].include?(@level)
    
    # Get kanji for the selected level
    @single_kanjis = KanjiSingle.by_rate(@level).order(:kanji)
    @multiple_kanjis = KanjiMultiple.by_rate(@level).order(:kanji)
    
    # Pagination
    @page = params[:page]&.to_i || 1
    @per_page = 20
    @kanji_type = params[:type] || 'single'
    
    if @kanji_type == 'single'
      @total_count = @single_kanjis.count
      offset = (@page - 1) * @per_page
      @kanjis = @single_kanjis.limit(@per_page).offset(offset)
    else
      @total_count = @multiple_kanjis.count
      offset = (@page - 1) * @per_page
      @kanjis = @multiple_kanjis.limit(@per_page).offset(offset)
    end
    
    @total_pages = (@total_count.to_f / @per_page).ceil
    
    # Statistics
    @stats = {
      single_count: @single_kanjis.count,
      multiple_count: @multiple_kanjis.count,
      total_count: @single_kanjis.count + @multiple_kanjis.count
    }
  end

  def show
    @kanji_type = params[:type] || 'single'
    @kanji_id = params[:id]
    
    if @kanji_type == 'single'
      @kanji = KanjiSingle.find(@kanji_id)
    else
      @kanji = KanjiMultiple.find(@kanji_id)
    end
    
    # Get user progress for this kanji if logged in
    if user_signed_in?
      @user_attempts = current_user.quiz_attempts
                                  .where(kanji_type: @kanji_type == 'single' ? 'KanjiSingle' : 'KanjiMultiple')
                                  .where(kanji_id: @kanji_id)
                                  .recent.limit(5)
      
      @user_stats = {
        total_attempts: @user_attempts.count,
        correct_attempts: @user_attempts.select(&:correct?).count,
        accuracy: @user_attempts.count > 0 ? (@user_attempts.select(&:correct?).count.to_f / @user_attempts.count * 100).round(1) : 0
      }
    end
    
    # Get similar kanji (same level)
    if @kanji_type == 'single'
      @similar_kanjis = KanjiSingle.by_rate(@kanji.rate).where.not(id: @kanji.id).limit(6)
    else
      @similar_kanjis = KanjiMultiple.by_rate(@kanji.rate).where.not(id: @kanji.id).limit(6)
    end
  end
end
