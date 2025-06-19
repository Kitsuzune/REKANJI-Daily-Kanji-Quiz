class ExamAnswer < ApplicationRecord
  belongs_to :exam_attempt
  
  # Serialize options as JSON
  serialize :options, coder: JSON

  validates :kanji_id, presence: true
  validates :kanji_type, presence: true, inclusion: { in: %w[KanjiSingle KanjiMultiple] }
  validates :question_type, presence: true, inclusion: { in: %w[kanji_to_meaning kanji_to_reading meaning_to_kanji reading_to_kanji] }
  validates :correct_answer, presence: true
  validates :question_number, presence: true, numericality: { greater_than: 0 }
  
  scope :correct, -> { where(is_correct: true) }
  scope :incorrect, -> { where(is_correct: false) }
  scope :by_question_type, ->(type) { where(question_type: type) }
  
  def kanji
    return KanjiSingle.find(kanji_id) if kanji_type == 'KanjiSingle'
    return KanjiMultiple.find(kanji_id) if kanji_type == 'KanjiMultiple'
  end
  
  def question_type_label
    case question_type
    when 'kanji_to_meaning'
      'Kanji → Arti'
    when 'kanji_to_reading'
      'Kanji → Cara Baca'
    when 'meaning_to_kanji'
      'Arti → Kanji'
    when 'reading_to_kanji'
      'Cara Baca → Kanji'
    end
  end
end
