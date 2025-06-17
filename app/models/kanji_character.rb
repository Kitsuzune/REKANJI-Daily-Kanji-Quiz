class KanjiCharacter < ApplicationRecord
  has_many :user_progresses, dependent: :destroy
  has_many :users, through: :user_progresses
  
  validates :character, presence: true, uniqueness: true
  validates :meaning, presence: true
  validates :reading, presence: true
  validates :level, presence: true, inclusion: { in: %w[N5 N4 N3] }
  
  scope :by_level, ->(level) { where(level: level) }
  scope :random_selection, ->(count) { order('RANDOM()').limit(count) }
end
