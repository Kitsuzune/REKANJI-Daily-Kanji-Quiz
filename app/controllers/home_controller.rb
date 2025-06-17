class HomeController < ApplicationController
  def index
    if user_signed_in?
      @total_kanjis = {
        'N5' => KanjiCharacter.by_level('N5').count,
        'N4' => KanjiCharacter.by_level('N4').count,
        'N3' => KanjiCharacter.by_level('N3').count
      }
      
      @user_progress = {
        'N5' => current_user.progress_for_level('N5').count,
        'N4' => current_user.progress_for_level('N4').count,
        'N3' => current_user.progress_for_level('N3').count
      }
      
      @recent_attempts = current_user.user_progresses.recent.includes(:kanji_character).limit(5)
    end
  end
end
