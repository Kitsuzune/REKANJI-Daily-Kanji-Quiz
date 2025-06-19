class CreateExamAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :exam_answers do |t|
      t.references :exam_attempt, null: false, foreign_key: true
      t.integer :kanji_id, null: false
      t.string :kanji_type, null: false # KanjiSingle, KanjiMultiple
      t.string :question_type, null: false # kanji_to_meaning, kanji_to_reading, meaning_to_kanji, reading_to_kanji
      t.text :question_text
      t.string :user_answer
      t.string :correct_answer, null: false
      t.boolean :is_correct, null: false
      t.integer :question_number, null: false

      t.timestamps
    end
    
    add_index :exam_answers, [:kanji_id, :kanji_type]
  end
end
