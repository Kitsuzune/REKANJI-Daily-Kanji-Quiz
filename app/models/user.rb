class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Role validation
  validates :role, inclusion: { in: %w[user superadmin] }
  after_initialize :set_default_role, if: :new_record?
  
  def superadmin?
    role == 'superadmin'
  end
  
  def user?
    role == 'user'
  end
  
  # Quiz attempts tracking
  has_many :quiz_attempts, dependent: :destroy
  
  # Exam attempts tracking
  has_many :exam_attempts, dependent: :destroy
  
  # Progress tracking methods
  def accuracy_for_level(level)
    attempts = quiz_attempts.by_level(level)
    return 0 if attempts.count == 0
    
    correct_count = attempts.correct.count
    (correct_count.to_f / attempts.count * 100).round(1)
  end
  
  def progress_for_kanji_type(kanji_type, level = nil)
    attempts = quiz_attempts.by_kanji_type(kanji_type)
    attempts = attempts.by_level(level) if level.present?
    
    return { attempted: 0, correct: 0, accuracy: 0 } if attempts.count == 0
    
    correct_count = attempts.correct.count
    {
      attempted: attempts.count,
      correct: correct_count,
      accuracy: (correct_count.to_f / attempts.count * 100).round(1)
    }
  end
  
  def total_attempts
    quiz_attempts.count
  end
  
  def total_correct
    quiz_attempts.correct.count
  end
  
  def overall_accuracy
    return 0 if total_attempts == 0
    (total_correct.to_f / total_attempts * 100).round(1)
  end
  
  private
  
  def set_default_role
    self.role ||= 'user'
  end
end
