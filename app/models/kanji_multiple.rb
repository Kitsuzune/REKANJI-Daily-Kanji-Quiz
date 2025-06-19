class KanjiMultiple < ApplicationRecord
  validates :rate, presence: true, inclusion: { in: %w[N5 N4 N3 N2 N1] }
  validates :kanji, presence: true, uniqueness: true
  validates :reading, presence: true
  validates :meaning_id, presence: true
  
  scope :by_rate, ->(rate) { where(rate: rate) }
  scope :random_sample, ->(limit) { order('RANDOM()').limit(limit) }
  
  def self.available_rates
    %w[N5 N4 N3 N2 N1]
  end
end
