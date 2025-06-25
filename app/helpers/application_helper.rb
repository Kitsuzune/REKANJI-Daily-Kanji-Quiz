module ApplicationHelper
  def get_clean_reading(kanji)
    # Get the first clean reading without parentheses
    readings = []
    readings << kanji.onyomi if kanji.onyomi.present? && !kanji.onyomi.include?('-')
    readings << kanji.kunyomi if kanji.kunyomi.present? && !kanji.kunyomi.include?('-')
    
    # Remove parentheses content and clean up
    clean_readings = readings.map do |reading|
      reading.gsub(/（[^）]*）/, '').gsub(/\([^)]*\)/, '').strip
    end.reject(&:empty?)
    
    clean_readings.first || kanji.onyomi || kanji.kunyomi || ""
  end
  
  # I18n helpers for kanji
  def kanji_meaning(kanji_or_string)
    # If it's already a string (like in quiz results), return as is
    return kanji_or_string if kanji_or_string.is_a?(String)
    
    # If it's a kanji object, use the appropriate field based on locale
    if I18n.locale == :en && kanji_or_string.respond_to?(:meaning_en) && kanji_or_string.meaning_en.present?
      kanji_or_string.meaning_en
    else
      kanji_or_string.meaning_id
    end
  end
  
  def kanji_description(kanji_or_string)
    # If it's already a string (like in quiz results), return as is
    return kanji_or_string if kanji_or_string.is_a?(String)
    
    # If it's a kanji object, use the appropriate field based on locale
    if I18n.locale == :en && kanji_or_string.respond_to?(:description_en) && kanji_or_string.description_en.present?
      kanji_or_string.description_en
    elsif kanji_or_string.respond_to?(:description_id) && kanji_or_string.description_id.present?
      kanji_or_string.description_id
    else
      kanji.description
    end
  end
  
  # Language switcher helper
  def language_switcher
    content_tag :div, class: "flex space-x-2" do
      I18n.available_locales.map do |locale|
        link_to locale.to_s.upcase, 
                url_for(locale: locale), 
                class: "px-3 py-1 rounded #{I18n.locale == locale ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}"
      end.join.html_safe
    end
  end
  
  # Time ago helper with proper locale handling
  def time_ago_with_locale(time)
    if I18n.locale == :id
      "#{time_ago_in_words(time)} yang lalu"
    else
      "#{time_ago_in_words(time)} ago"
    end
  end
  
  # Exam result helpers
  def score_color_class(score)
    case score
    when 90..100
      'text-green-600 bg-green-600'
    when 70..89
      'text-yellow-600 bg-yellow-600'
    else
      'text-red-600 bg-red-600'
    end
  end
  
  def score_status(score)
    case score
    when 90..100
      'Excellent!'
    when 70..89
      'Good Job!'
    else
      'Keep Practicing!'
    end
  end
  
  def time_taken(exam_attempt)
    return 'N/A' unless exam_attempt.completed_at && exam_attempt.started_at
    
    duration = exam_attempt.completed_at - exam_attempt.started_at
    minutes = (duration / 60).to_i
    seconds = (duration % 60).to_i
    
    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
  end
  
  def mode_japanese(mode)
    case mode
    when 'casual'
      '(楽)'
    when 'ambitious'
      '(挑)'
    when 'dedicated'
      '(努)'
    else
      ''
    end
  end
  
  def format_question_type(type)
    case type
    when 'kanji_to_meaning'
      'Kanji to Meaning'
    when 'kanji_to_reading'
      'Kanji to Reading'
    when 'meaning_to_kanji'
      'Meaning to Kanji'
    when 'reading_to_kanji'
      'Reading to Kanji'
    else
      type.humanize
    end
  end
  
  def question_type_stats(exam_attempt)
    stats = {}
    exam_attempt.exam_answers.group(:question_type).each do |type, answers|
      correct = answers.select(&:is_correct?).count
      total = answers.count
      percentage = total > 0 ? (correct.to_f / total * 100).round(1) : 0
      
      stats[type] = {
        correct: correct,
        total: total,
        percentage: percentage
      }
    end
    stats
  end
end
