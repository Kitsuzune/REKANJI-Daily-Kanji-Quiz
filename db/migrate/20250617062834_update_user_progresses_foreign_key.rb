class UpdateUserProgressesForeignKey < ActiveRecord::Migration[7.1]
  def change
    rename_column :user_progresses, :kanji_id, :kanji_character_id
  end
end
