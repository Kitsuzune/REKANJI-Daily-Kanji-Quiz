class UserProgress < ApplicationRecord
  belongs_to :user
  belongs_to :kanji_character
  
  validates :is_correct, inclusion: { in: [true, false] }
  validates :attempted_at, presence: true
  
  scope :correct, -> { where(is_correct: true) }
  scope :incorrect, -> { where(is_correct: false) }
  scope :recent, -> { order(attempted_at: :desc) }
end
