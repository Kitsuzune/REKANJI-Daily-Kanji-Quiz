class CreateKanjis < ActiveRecord::Migration[7.1]
  def change
    create_table :kanjis do |t|
      t.string :character
      t.string :meaning
      t.string :reading
      t.string :level

      t.timestamps
    end
  end
end
