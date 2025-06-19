class QuizController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user_or_superadmin
  
  def index
    @levels = %w[N5 N4 N3]
    @kanji_single_counts = {
      'N5' => KanjiSingle.by_rate('N5').count,
      'N4' => KanjiSingle.by_rate('N4').count,
      'N3' => KanjiSingle.by_rate('N3').count
    }
    @kanji_multiple_counts = {
      'N5' => KanjiMultiple.by_rate('N5').count,
      'N4' => KanjiMultiple.by_rate('N4').count,
      'N3' => KanjiMultiple.by_rate('N3').count
    }
  end

  def single
    @level = params[:level]
    redirect_to quiz_path unless %w[N5 N4 N3].include?(@level)
    
    @kanji = KanjiSingle.by_rate(@level).random_sample(1).first
    redirect_to quiz_path, alert: "No single kanji available for #{@level}" unless @kanji
    
    if @kanji
      # Randomly choose question type (1-4)
      @question_type = rand(1..4)
      @options = generate_single_options(@kanji, @question_type)
      session[:current_kanji_id] = @kanji.id
      session[:current_level] = @level
      session[:quiz_mode] = 'single'
      session[:quiz_type] = 'single'
      session[:question_type] = @question_type
    end
  end

  def multiple
    @level = params[:level]
    redirect_to quiz_path unless %w[N5 N4 N3].include?(@level)
    
    @kanji = KanjiMultiple.by_rate(@level).random_sample(1).first
    redirect_to quiz_path, alert: "No multiple kanji available for #{@level}" unless @kanji
    
    if @kanji
      # Generate multiple choice options for multiple kanji (jyukugo)
      @options = generate_multiple_options(@kanji)
      session[:current_kanji_id] = @kanji.id
      session[:current_level] = @level
      session[:quiz_mode] = 'multiple'
      session[:quiz_type] = 'multiple'
    end
  end
  
  def answer
    quiz_type = session[:quiz_type]
    kanji_id = session[:current_kanji_id]
    question_type = session[:question_type] || 1
    
    if quiz_type == 'single'
      kanji = KanjiSingle.find_by(id: kanji_id)
    else
      kanji = KanjiMultiple.find_by(id: kanji_id)
    end
    
    if kanji.nil?
      redirect_to quiz_path, alert: "Session expired" 
      return
    end
    
    selected_answer = params[:answer]&.strip
    
    # Determine correct answer based on question type
    correct_answer = case question_type
                    when 1 # Kanji -> Meaning
                      kanji.meaning_id.strip
                    when 2 # Kanji -> Reading
                      if quiz_type == 'single'
                        # Get clean reading without parentheses for single kanji
                        get_clean_reading(kanji)
                      else
                        kanji.reading.strip
                      end
                    when 3 # Meaning -> Kanji
                      kanji.kanji.strip
                    when 4 # Reading -> Kanji
                      kanji.kanji.strip
                    else
                      kanji.meaning_id.strip
                    end
    
    is_correct = selected_answer == correct_answer
    
    # Debug logging
    Rails.logger.debug "Question type: #{question_type}"
    Rails.logger.debug "Selected answer: '#{selected_answer}'"
    Rails.logger.debug "Correct answer: '#{correct_answer}'"
    Rails.logger.debug "Is correct: #{is_correct}"
    
    # Record quiz attempt for logged-in users
    if current_user
      current_user.quiz_attempts.create!(
        quiz_type: quiz_type,
        kanji_type: quiz_type == 'single' ? 'KanjiSingle' : 'KanjiMultiple',
        level: session[:current_level],
        kanji_id: kanji.id,
        correct: is_correct,
        answered_at: Time.current
      )
    end
    
    session[:last_result] = {
      "kanji" => kanji.kanji,
      "meaning" => kanji.meaning_id,
      "reading" => quiz_type == 'single' ? kanji.display_reading : kanji.reading,
      "selected" => selected_answer,
      "correct_answer" => correct_answer,
      "is_correct" => is_correct,
      "rate" => kanji.rate,
      "quiz_type" => quiz_type,
      "question_type" => question_type,
      "description" => quiz_type == 'single' ? kanji.description_id : nil
    }
    
    redirect_to quiz_result_path
  end
  
  def result
    @result = session[:last_result]
    Rails.logger.debug "Session result: #{@result.inspect}"
    if @result
      Rails.logger.debug "is_correct value: #{@result[:is_correct].inspect} (class: #{@result[:is_correct].class})"
    end
    redirect_to quiz_path, alert: "No quiz result to show" unless @result
  end
  
  private
  
  def generate_single_options(kanji, question_type = 1)
    case question_type
    when 1 # Kanji -> Meaning
      correct_answer = kanji.meaning_id
      wrong_kanjis = KanjiSingle.by_rate(kanji.rate).where.not(id: kanji.id).random_sample(3)
      if wrong_kanjis.count < 3
        additional_needed = 3 - wrong_kanjis.count
        additional_kanjis = KanjiSingle.where.not(id: [kanji.id] + wrong_kanjis.pluck(:id))
                                 .random_sample(additional_needed)
        wrong_kanjis += additional_kanjis
      end
      wrong_answers = wrong_kanjis.pluck(:meaning_id)
      
    when 2 # Kanji -> Reading
      correct_answer = get_clean_reading(kanji)
      wrong_kanjis = KanjiSingle.by_rate(kanji.rate).where.not(id: kanji.id).random_sample(3)
      if wrong_kanjis.count < 3
        additional_needed = 3 - wrong_kanjis.count
        additional_kanjis = KanjiSingle.where.not(id: [kanji.id] + wrong_kanjis.pluck(:id))
                                 .random_sample(additional_needed)
        wrong_kanjis += additional_kanjis
      end
      wrong_answers = wrong_kanjis.map { |k| get_clean_reading(k) }
      
    when 3 # Meaning -> Kanji
      correct_answer = kanji.kanji
      wrong_kanjis = KanjiSingle.by_rate(kanji.rate).where.not(id: kanji.id).random_sample(3)
      if wrong_kanjis.count < 3
        additional_needed = 3 - wrong_kanjis.count
        additional_kanjis = KanjiSingle.where.not(id: [kanji.id] + wrong_kanjis.pluck(:id))
                                 .random_sample(additional_needed)
        wrong_kanjis += additional_kanjis
      end
      wrong_answers = wrong_kanjis.pluck(:kanji)
      
    when 4 # Reading -> Kanji
      correct_answer = kanji.kanji
      wrong_kanjis = KanjiSingle.by_rate(kanji.rate).where.not(id: kanji.id).random_sample(3)
      if wrong_kanjis.count < 3
        additional_needed = 3 - wrong_kanjis.count
        additional_kanjis = KanjiSingle.where.not(id: [kanji.id] + wrong_kanjis.pluck(:id))
                                 .random_sample(additional_needed)
        wrong_kanjis += additional_kanjis
      end
      wrong_answers = wrong_kanjis.pluck(:kanji)
      
    else
      correct_answer = kanji.meaning_id
      wrong_kanjis = KanjiSingle.by_rate(kanji.rate).where.not(id: kanji.id).random_sample(3)
      wrong_answers = wrong_kanjis.pluck(:meaning_id)
    end
    
    options = ([correct_answer] + wrong_answers).shuffle
    
    # Debug logging
    Rails.logger.debug "Generated single options for type #{question_type}: #{options.inspect}"
    Rails.logger.debug "Correct answer: '#{correct_answer}'"
    
    options
  end
  
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
  
  def generate_multiple_options(kanji)
    correct_answer = kanji.meaning_id
    
    # Get wrong options from the same rate
    wrong_kanjis = KanjiMultiple.by_rate(kanji.rate).where.not(id: kanji.id).random_sample(3)
    
    # If not enough options in the same rate, get from other rates
    if wrong_kanjis.count < 3
      additional_needed = 3 - wrong_kanjis.count
      additional_kanjis = KanjiMultiple.where.not(id: [kanji.id] + wrong_kanjis.pluck(:id))
                                .random_sample(additional_needed)
      wrong_kanjis += additional_kanjis
    end
    
    wrong_answers = wrong_kanjis.pluck(:meaning_id)
    options = ([correct_answer] + wrong_answers).shuffle
    
    # Debug logging
    Rails.logger.debug "Generated multiple options: #{options.inspect}"
    Rails.logger.debug "Correct answer: '#{correct_answer}'"
    
    options
  end
end
