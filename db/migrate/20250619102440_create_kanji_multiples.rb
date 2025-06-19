class CreateKanjiMultiples < ActiveRecord::Migration[7.1]
  def change
    create_table :kanji_multiples do |t|
      t.string :rate, null: false
      t.string :kanji, null: false
      t.string :reading, null: false
      t.text :meaning_id, null: false
      t.text :description_id

      t.timestamps
    end
    
    add_index :kanji_multiples, :rate
    add_index :kanji_multiples, :kanji, unique: true
  end
end
