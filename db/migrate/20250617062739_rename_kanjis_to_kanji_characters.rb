class RenameKanjisToKanjiCharacters < ActiveRecord::Migration[7.1]
  def change
    rename_table :kanjis, :kanji_characters
  end
end
