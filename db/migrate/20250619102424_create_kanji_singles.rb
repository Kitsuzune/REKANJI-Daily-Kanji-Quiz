class CreateKanjiSingles < ActiveRecord::Migration[7.1]
  def change
    create_table :kanji_singles do |t|
      t.string :rate, null: false
      t.string :kanji, null: false
      t.string :onyomi
      t.string :kunyomi
      t.text :meaning_id, null: false
      t.text :description_id

      t.timestamps
    end
    
    add_index :kanji_singles, :rate
    add_index :kanji_singles, :kanji, unique: true
  end
end
