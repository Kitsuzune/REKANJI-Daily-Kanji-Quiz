class CreateExamAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :exam_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :level, null: false # N5, N4, N3
      t.string :exam_mode, null: false # casual, ambitious, dedicated
      t.integer :total_questions, null: false
      t.integer :correct_answers, default: 0
      t.decimal :score, precision: 5, scale: 2 # 0.00 to 100.00
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.integer :time_limit_minutes, null: false # 25, 45, 60
      t.boolean :show_meaning, default: false
      t.boolean :show_reading, default: false

      t.timestamps
    end
    
    add_index :exam_attempts, [:user_id, :level]
    add_index :exam_attempts, [:user_id, :exam_mode]
    add_index :exam_attempts, :completed_at
  end
end
