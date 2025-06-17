class CreateUserProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :user_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :kanji, null: false, foreign_key: true
      t.boolean :is_correct
      t.datetime :attempted_at

      t.timestamps
    end
  end
end
