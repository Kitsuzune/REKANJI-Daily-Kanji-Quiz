class QuizAttempt < ApplicationRecord
  belongs_to :user
  
  validates :quiz_type, presence: true, inclusion: { in: %w[single multiple] }
  validates :kanji_type, presence: true, inclusion: { in: %w[KanjiSingle KanjiMultiple] }
  validates :level, presence: true, inclusion: { in: %w[N5 N4 N3] }
  validates :kanji_id, presence: true
  validates :correct, inclusion: { in: [true, false] }
  validates :answered_at, presence: true
  
  scope :correct, -> { where(correct: true) }
  scope :incorrect, -> { where(correct: false) }
  scope :by_quiz_type, ->(type) { where(quiz_type: type) }
  scope :by_level, ->(level) { where(level: level) }
  scope :by_kanji_type, ->(type) { where(kanji_type: type) }
  scope :recent, -> { order(answered_at: :desc) }
  
  def kanji
    return KanjiSingle.find(kanji_id) if kanji_type == 'KanjiSingle'
    return KanjiMultiple.find(kanji_id) if kanji_type == 'KanjiMultiple'
  end
end
