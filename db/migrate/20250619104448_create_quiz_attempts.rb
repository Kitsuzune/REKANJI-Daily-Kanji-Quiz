class CreateQuizAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :quiz_type, null: false # 'single' or 'multiple'
      t.string :kanji_type, null: false # 'KanjiSingle' or 'KanjiMultiple' 
      t.string :level, null: false # 'N5', 'N4', 'N3'
      t.integer :kanji_id, null: false
      t.boolean :correct, null: false
      t.datetime :answered_at

      t.timestamps
    end
    
    add_index :quiz_attempts, [:user_id, :quiz_type]
    add_index :quiz_attempts, [:user_id, :level]
    add_index :quiz_attempts, [:user_id, :kanji_type]
  end
end
