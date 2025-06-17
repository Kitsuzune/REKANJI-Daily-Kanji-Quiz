class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :user_progresses, dependent: :destroy
  has_many :kanji_characters, through: :user_progresses
  
  def progress_for_level(level)
    user_progresses.joins(:kanji_character).where(kanji_characters: {level: level})
  end
  
  def correct_answers_for_level(level)
    user_progresses.joins(:kanji_character).where(kanji_characters: {level: level}, is_correct: true)
  end
end
