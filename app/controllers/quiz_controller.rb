class QuizController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @levels = %w[N5 N4 N3]
    @kanji_counts = {
      'N5' => KanjiCharacter.by_level('N5').count,
      'N4' => KanjiCharacter.by_level('N4').count,
      'N3' => KanjiCharacter.by_level('N3').count
    }
  end

  def practice
    @level = params[:level]
    redirect_to quiz_path unless %w[N5 N4 N3].include?(@level)
    
    @kanji = KanjiCharacter.by_level(@level).random_selection(1).first
    redirect_to quiz_path, alert: "No kanji available for #{@level}" unless @kanji
    
    if @kanji
      # Generate multiple choice options
      @options = generate_options(@kanji)
      session[:current_kanji_id] = @kanji.id
      session[:current_level] = @level
    end
  end

  def single
    @level = params[:level]
    redirect_to quiz_path unless %w[N5 N4 N3].include?(@level)
    
    # Same as practice but single mode
    @kanji = KanjiCharacter.by_level(@level).random_selection(1).first
    redirect_to quiz_path, alert: "No kanji available for #{@level}" unless @kanji
    
    if @kanji
      @options = generate_options(@kanji)
      session[:current_kanji_id] = @kanji.id
      session[:current_level] = @level
      session[:quiz_mode] = 'single'
    end
  end

  def mixed
    @kanji = KanjiCharacter.random_selection(1).first
    redirect_to quiz_path, alert: "No kanji available" unless @kanji
    
    if @kanji
      @options = generate_options(@kanji, mixed: true)
      session[:current_kanji_id] = @kanji.id
      session[:quiz_mode] = 'mixed'
    end
  end
  
  def answer
    kanji = KanjiCharacter.find_by(id: session[:current_kanji_id])
    if kanji.nil?
      redirect_to quiz_path, alert: "Session expired" 
      return
    end
    
    selected_answer = params[:answer]&.strip
    is_correct = selected_answer == kanji.meaning.strip
    
    # Debug logging
    Rails.logger.debug "Selected answer: '#{selected_answer}'"
    Rails.logger.debug "Correct answer: '#{kanji.meaning}'"
    Rails.logger.debug "Is correct: #{is_correct}"
    
    # Record user progress
    current_user.user_progresses.create!(
      kanji_character: kanji,
      is_correct: is_correct,
      attempted_at: Time.current
    )
    
    session[:last_result] = {
      "kanji" => kanji.character,
      "meaning" => kanji.meaning,
      "reading" => kanji.reading,
      "selected" => selected_answer,
      "is_correct" => is_correct,
      "level" => kanji.level
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
  
  def generate_options(kanji, mixed: false)
    correct_answer = kanji.meaning
    
    # Get wrong options from the same level or mixed levels
    if mixed
      wrong_kanjis = KanjiCharacter.where.not(id: kanji.id).random_selection(3)
    else
      wrong_kanjis = KanjiCharacter.by_level(kanji.level).where.not(id: kanji.id).random_selection(3)
      # If not enough options in the same level, get from other levels
      if wrong_kanjis.count < 3
        additional_needed = 3 - wrong_kanjis.count
        additional_kanjis = KanjiCharacter.where.not(id: [kanji.id] + wrong_kanjis.pluck(:id))
                                 .random_selection(additional_needed)
        wrong_kanjis += additional_kanjis
      end
    end
    
    wrong_answers = wrong_kanjis.pluck(:meaning)
    options = ([correct_answer] + wrong_answers).shuffle
    
    # Debug logging
    Rails.logger.debug "Generated options: #{options.inspect}"
    Rails.logger.debug "Correct answer: '#{correct_answer}'"
    
    options
  end
end
