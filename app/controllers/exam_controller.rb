class ExamController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exam_attempt, only: [:show, :answer, :result]
  before_action :check_exam_access, only: [:show, :answer]
  
  def index
    @levels = %w[N5 N4 N3]
    @exam_modes = [
      {
        key: 'casual',
        name: 'Casual',
        kanji: '楽',
        description: 'Diperuntukan untuk fast paced learning dengan bantuan arti dan cara baca kanji',
        questions: 12,
        time_minutes: 25,
        show_meaning: true,
        show_reading: true,
        color: 'green',
        bg_color: 'bg-green-100',
        border_color: 'border-green-300',
        text_color: 'text-green-800'
      },
      {
        key: 'ambitious',
        name: 'Ambitious',
        kanji: '挑',
        description: 'Diperuntukan untuk yang mengetes pengetahuan lebih dalam tanpa bantuan arti kanji',
        questions: 30,
        time_minutes: 45,
        show_meaning: false,
        show_reading: true,
        color: 'orange',
        bg_color: 'bg-orange-100',
        border_color: 'border-orange-300',
        text_color: 'text-orange-800'
      },
      {
        key: 'dedicated',
        name: 'Dedicated',
        kanji: '努',
        description: 'Diperuntukan untuk yang ingin menchallenge pengetahuannya dengan waktu yang fair',
        questions: 50,
        time_minutes: 60,
        show_meaning: false,
        show_reading: false,
        color: 'red',
        bg_color: 'bg-red-100',
        border_color: 'border-red-300',
        text_color: 'text-red-800'
      }
    ]
  end

  def start
    level = params[:level]
    exam_mode = params[:exam_mode]
    
    unless %w[N5 N4 N3].include?(level) && %w[casual ambitious dedicated].include?(exam_mode)
      redirect_to exam_path, alert: 'Invalid exam parameters'
      return
    end
    
    # Check if user has an incomplete exam
    existing_exam = current_user.exam_attempts.in_progress.first
    if existing_exam
      redirect_to exam_show_path(existing_exam), notice: 'You have an incomplete exam. Please complete it first.'
      return
    end
    
    mode_config = ExamAttempt.new(exam_mode: exam_mode).mode_config
    
    @exam_attempt = current_user.exam_attempts.create!(
      level: level,
      exam_mode: exam_mode,
      total_questions: mode_config[:questions],
      time_limit_minutes: mode_config[:time_minutes],
      show_meaning: mode_config[:show_meaning],
      show_reading: mode_config[:show_reading],
      started_at: Time.current
    )
    
    generate_exam_questions(@exam_attempt)
    
    # Initialize session for question tracking
    session[:current_question_number] = 1
    
    redirect_to exam_show_path(@exam_attempt)
  end

  def show
    @current_question_number = session[:current_question_number] || 1
    @current_question_index = @current_question_number
    @total_questions = @exam_attempt.total_questions
    
    # Calculate time remaining in seconds for more accurate calculation
    elapsed_seconds = Time.current - @exam_attempt.started_at
    total_seconds = @exam_attempt.time_limit_minutes * 60
    remaining_seconds = [total_seconds - elapsed_seconds, 0].max
    @time_remaining = (remaining_seconds / 60.0).round(2) # in minutes with 2 decimal places
    
    # Check if exam is completed or time expired
    if @exam_attempt.completed_at.present? || remaining_seconds <= 0
      redirect_to exam_result_path(@exam_attempt)
      return
    end
    
    # Debug logging
    Rails.logger.debug "Looking for question number: #{@current_question_number}"
    Rails.logger.debug "Total exam answers: #{@exam_attempt.exam_answers.count}"
    
    @current_answer = @exam_attempt.exam_answers.find_by(question_number: @current_question_number)
    
    # Check if we've reached the end of questions
    if @current_answer.nil?
      if @current_question_number > @exam_attempt.total_questions
        complete_exam(@exam_attempt)
        redirect_to exam_result_path(@exam_attempt), notice: 'Exam completed!'
        return
      else
        # This shouldn't happen - question should exist
        Rails.logger.error "Question #{@current_question_number} not found for exam #{@exam_attempt.id}"
        redirect_to exam_path, alert: 'Invalid question. Please restart the exam.'
        return
      end
    end
    
    # Set @question for the view
    @question = {
      type: @current_answer.question_type,
      kanji: @current_answer.kanji,
      text: @current_answer.question_text,
      options: @current_answer.options || []
    }
    
    # Add specific data based on question type
    case @current_answer.question_type
    when 'reading_to_kanji'
      @question[:correct_reading] = @current_answer.question_text
    when 'meaning_to_kanji'
      @question[:meaning] = @current_answer.question_text
    end
    
    @options = @question[:options]
    @progress_percentage = ((@current_question_number - 1).to_f / @exam_attempt.total_questions * 100).round
    
    # Check if time expired
    if @exam_attempt.time_expired?
      complete_exam(@exam_attempt)
      redirect_to exam_result_path(@exam_attempt), alert: 'Time expired!'
    end
  end

  def answer
    current_question_number = session[:current_question_number] || 1
    user_answer = params[:answer]&.strip
    
    Rails.logger.debug "Processing answer for question number: #{current_question_number}"
    
    exam_answer = @exam_attempt.exam_answers.find_by(question_number: current_question_number)
    
    if exam_answer.nil?
      Rails.logger.debug "Could not find exam_answer for question_number: #{current_question_number}"
      redirect_to exam_show_path(@exam_attempt), alert: 'Invalid question'
      return
    end
    
    is_correct = user_answer == exam_answer.correct_answer
    exam_answer.update!(
      user_answer: user_answer,
      is_correct: is_correct
    )
    
    next_question = current_question_number + 1
    session[:current_question_number] = next_question
    
    Rails.logger.debug "Updated session to question number: #{next_question}"
    
    if next_question > @exam_attempt.total_questions
      complete_exam(@exam_attempt)
      redirect_to exam_result_path(@exam_attempt)
    else
      redirect_to exam_show_path(@exam_attempt)
    end
  end

  def result
    unless @exam_attempt.completed?
      redirect_to exam_show_path(@exam_attempt), alert: 'Exam not completed yet'
      return
    end
    
    @exam_answers = @exam_attempt.exam_answers.order(:question_number)
    @correct_count = @exam_answers.correct.count
    @total_questions = @exam_attempt.total_questions
    @score = @exam_attempt.score
    @duration = @exam_attempt.duration_minutes
  end

  def history
    @exam_attempts = current_user.exam_attempts.completed.order(started_at: :desc).includes(:exam_answers)
    @stats = {
      total_exams: @exam_attempts.count,
      average_score: @exam_attempts.average(:score)&.round(1) || 0,
      best_score: @exam_attempts.maximum(:score) || 0,
      exams_by_level: current_user.exam_attempts.completed.group(:level).count,
      exams_by_mode: current_user.exam_attempts.completed.group(:exam_mode).count
    }
  end

  private

  def set_exam_attempt
    @exam_attempt = current_user.exam_attempts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to exam_path, alert: 'Exam not found'
  end

  def check_exam_access
    if @exam_attempt.completed?
      redirect_to exam_result_path(@exam_attempt)
    end
  end

  def generate_exam_questions(exam_attempt)
    # Get kanji for the level
    single_kanjis = KanjiSingle.by_rate(exam_attempt.level).to_a
    multiple_kanjis = KanjiMultiple.by_rate(exam_attempt.level).to_a
    all_kanjis = single_kanjis + multiple_kanjis
    
    Rails.logger.debug "Found #{all_kanjis.count} kanjis for level #{exam_attempt.level}"
    
    return if all_kanjis.empty?
    
    selected_kanjis = all_kanjis.sample(exam_attempt.total_questions)
    question_types = %w[kanji_to_meaning kanji_to_reading meaning_to_kanji reading_to_kanji]
    
    selected_kanjis.each_with_index do |kanji, index|
      question_type = question_types.sample
      
      # Skip reading questions if reading should not be shown
      if !exam_attempt.show_reading && %w[kanji_to_reading reading_to_kanji].include?(question_type)
        question_type = %w[kanji_to_meaning meaning_to_kanji].sample
      end
      
      kanji_type = kanji.class.name
      correct_answer = get_correct_answer(kanji, question_type)
      question_text = get_question_text(kanji, question_type, exam_attempt)
      
      Rails.logger.debug "Creating question #{index + 1}: type=#{question_type}, kanji=#{kanji.kanji}, answer=#{correct_answer}"
      
      # Create the exam answer first
      exam_answer = exam_attempt.exam_answers.create!(
        kanji_id: kanji.id,
        kanji_type: kanji_type,
        question_type: question_type,
        question_text: question_text,
        correct_answer: correct_answer,
        question_number: index + 1,
        is_correct: false
      )
      
      # Generate and save options for this question
      options = generate_question_options(exam_answer)
      exam_answer.update!(options: options)
    end
    
    Rails.logger.debug "Created #{exam_attempt.exam_answers.count} exam questions"
  end

  def get_correct_answer(kanji, question_type)
    case question_type
    when 'kanji_to_meaning'
      kanji.meaning_id
    when 'kanji_to_reading'
      if kanji.respond_to?(:display_reading)
        get_clean_reading(kanji)
      else
        kanji.reading
      end
    when 'meaning_to_kanji'
      kanji.kanji
    when 'reading_to_kanji'
      kanji.kanji
    end
  end

  def get_question_text(kanji, question_type, exam_attempt)
    base_text = case question_type
    when 'kanji_to_meaning'
      "Apa arti dari kanji: #{kanji.kanji}?"
    when 'kanji_to_reading'
      "Bagaimana cara baca kanji: #{kanji.kanji}?"
    when 'meaning_to_kanji'
      "Kanji mana yang memiliki arti: #{kanji.meaning_id}?"
    when 'reading_to_kanji'
      reading = kanji.respond_to?(:display_reading) ? get_clean_reading(kanji) : kanji.reading
      "Kanji mana yang dibaca: #{reading}?"
    else
      "Unknown question type"
    end
    
    # Add hints if allowed
    hints = []
    if exam_attempt.show_meaning && !%w[kanji_to_meaning meaning_to_kanji].include?(question_type)
      hints << "Arti: #{kanji.meaning_id}"
    end
    
    if exam_attempt.show_reading && !%w[kanji_to_reading reading_to_kanji].include?(question_type)
      reading = kanji.respond_to?(:display_reading) ? kanji.display_reading : kanji.reading
      hints << "Cara baca: #{reading}"
    end
    
    base_text + (hints.any? ? " (#{hints.join(', ')})" : "")
  end

  def generate_question_options(exam_answer)
    kanji = exam_answer.kanji
    question_type = exam_answer.question_type
    correct_answer = exam_answer.correct_answer
    
    case question_type
    when 'kanji_to_meaning'
      # Get wrong meanings from same level
      wrong_kanjis = get_similar_kanjis(kanji, 3)
      wrong_answers = wrong_kanjis.map(&:meaning_id)
    when 'kanji_to_reading'
      # Get wrong readings from same level
      wrong_kanjis = get_similar_kanjis(kanji, 3)
      wrong_answers = wrong_kanjis.map { |k| k.respond_to?(:display_reading) ? get_clean_reading(k) : k.reading }
    when 'meaning_to_kanji', 'reading_to_kanji'
      # Get wrong kanji characters from same level
      wrong_kanjis = get_similar_kanjis(kanji, 3)
      wrong_answers = wrong_kanjis.map(&:kanji)
    end
    
    ([correct_answer] + wrong_answers).uniq.shuffle
  end

  def get_similar_kanjis(kanji, count)
    level = @exam_attempt.level
    kanji_type = kanji.class.name
    
    if kanji_type == 'KanjiSingle'
      similar = KanjiSingle.by_rate(level).where.not(id: kanji.id).limit(count * 2).to_a
    else
      similar = KanjiMultiple.by_rate(level).where.not(id: kanji.id).limit(count * 2).to_a
    end
    
    # If not enough from same level, get from other levels
    if similar.count < count
      additional_needed = count - similar.count
      if kanji_type == 'KanjiSingle'
        additional = KanjiSingle.where.not(id: [kanji.id] + similar.map(&:id)).limit(additional_needed).to_a
      else
        additional = KanjiMultiple.where.not(id: [kanji.id] + similar.map(&:id)).limit(additional_needed).to_a
      end
      similar += additional
    end
    
    similar.sample(count)
  end

  def complete_exam(exam_attempt)
    correct_answers = exam_attempt.exam_answers.correct.count
    score = (correct_answers.to_f / exam_attempt.total_questions * 100).round(2)
    
    exam_attempt.update!(
      correct_answers: correct_answers,
      score: score,
      completed_at: Time.current
    )
  end

  
  def generate_question_text(exam_answer)
    kanji = exam_answer.kanji
    case exam_answer.question_type
    when 'kanji_to_meaning'
      "Apa arti dari kanji: #{kanji.kanji}?"
    when 'kanji_to_reading'
      "Bagaimana cara baca kanji: #{kanji.kanji}?"
    when 'meaning_to_kanji'
      "Kanji mana yang memiliki arti: #{kanji.meaning_id}?"
    when 'reading_to_kanji'
      reading = kanji.respond_to?(:display_reading) ? get_clean_reading(kanji) : kanji.reading
      "Kanji mana yang dibaca: #{reading}?"
    else
      exam_answer.question_text
    end
  end

  def get_clean_reading(kanji)
    return kanji.reading unless kanji.respond_to?(:onyomi) && kanji.respond_to?(:kunyomi)
    
    readings = []
    readings << kanji.onyomi if kanji.onyomi.present? && !kanji.onyomi.include?('-')
    readings << kanji.kunyomi if kanji.kunyomi.present? && !kanji.kunyomi.include?('-')
    
    readings.reject(&:blank?).first || kanji.reading || ''
  end
end
