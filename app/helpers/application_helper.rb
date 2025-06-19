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
