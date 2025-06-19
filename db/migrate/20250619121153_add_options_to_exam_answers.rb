class AddOptionsToExamAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :exam_answers, :options, :text
  end
end
