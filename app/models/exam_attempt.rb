class ExamAttempt < ApplicationRecord
  belongs_to :user
  has_many :exam_answers, dependent: :destroy
  
  validates :level, presence: true, inclusion: { in: %w[N5 N4 N3] }
  validates :exam_mode, presence: true, inclusion: { in: %w[casual ambitious dedicated] }
  validates :total_questions, presence: true, numericality: { greater_than: 0 }
  validates :time_limit_minutes, presence: true, numericality: { greater_than: 0 }
  validates :started_at, presence: true
  
  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }
  scope :by_level, ->(level) { where(level: level) }
  scope :by_mode, ->(mode) { where(exam_mode: mode) }
  scope :recent, -> { order(started_at: :desc) }
  
  def completed?
    completed_at.present?
  end
  
  def in_progress?
    !completed?
  end
  
  def duration_minutes
    return nil unless completed?
    ((completed_at - started_at) / 60).round
  end
  
  def time_remaining_minutes
    return 0 if completed?
    elapsed_minutes = ((Time.current - started_at) / 60).round
    [time_limit_minutes - elapsed_minutes, 0].max
  end
  
  def time_expired?
    return false if completed?
    time_remaining_minutes <= 0
  end
  
  def accuracy_percentage
    return 0 if total_questions == 0
    (correct_answers.to_f / total_questions * 100).round(2)
  end
  
  def score_color_class
    case score.to_f
    when 90..100
      'text-green-600'
    when 70..89
      'text-yellow-600'
    else
      'text-red-600'
    end
  end
  
  def score_bg_color_class
    case score.to_f
    when 90..100
      'bg-green-100'
    when 70..89
      'bg-yellow-100'
    else
      'bg-red-100'
    end
  end
  
  def mode_config
    case exam_mode
    when 'casual'
      {
        name: 'Casual',
        kanji: '楽',
        questions: 12,
        time_minutes: 25,
        show_meaning: true,
        show_reading: true,
        color: 'green'
      }
    when 'ambitious'
      {
        name: 'Ambitious',
        kanji: '挑',
        questions: 30,
        time_minutes: 45,
        show_meaning: false,
        show_reading: true,
        color: 'orange'
      }
    when 'dedicated'
      {
        name: 'Dedicated',
        kanji: '努',
        questions: 50,
        time_minutes: 60,
        show_meaning: false,
        show_reading: false,
        color: 'red'
      }
    end
  end
end
