class AddEnglishMeaningAndDescriptionToKanjis < ActiveRecord::Migration[7.1]
  def change
    add_column :kanji_singles, :meaning_en, :string
    add_column :kanji_singles, :description_en, :text

    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with?('mysql')
      execute "ALTER TABLE kanji_singles MODIFY COLUMN meaning_en VARCHAR(255) AFTER meaning_id"
      execute "ALTER TABLE kanji_singles MODIFY COLUMN description_en TEXT AFTER description_id"
    end
  end
end