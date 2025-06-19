# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_06_19_121153) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exam_answers", force: :cascade do |t|
    t.bigint "exam_attempt_id", null: false
    t.integer "kanji_id", null: false
    t.string "kanji_type", null: false
    t.string "question_type", null: false
    t.text "question_text"
    t.string "user_answer"
    t.string "correct_answer", null: false
    t.boolean "is_correct", null: false
    t.integer "question_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "options"
    t.index ["exam_attempt_id"], name: "index_exam_answers_on_exam_attempt_id"
    t.index ["kanji_id", "kanji_type"], name: "index_exam_answers_on_kanji_id_and_kanji_type"
  end

  create_table "exam_attempts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "level", null: false
    t.string "exam_mode", null: false
    t.integer "total_questions", null: false
    t.integer "correct_answers", default: 0
    t.decimal "score", precision: 5, scale: 2
    t.datetime "started_at", null: false
    t.datetime "completed_at"
    t.integer "time_limit_minutes", null: false
    t.boolean "show_meaning", default: false
    t.boolean "show_reading", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_at"], name: "index_exam_attempts_on_completed_at"
    t.index ["user_id", "exam_mode"], name: "index_exam_attempts_on_user_id_and_exam_mode"
    t.index ["user_id", "level"], name: "index_exam_attempts_on_user_id_and_level"
    t.index ["user_id"], name: "index_exam_attempts_on_user_id"
  end

  create_table "kanji_characters", force: :cascade do |t|
    t.string "character"
    t.string "meaning"
    t.string "reading"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kanji_multiples", force: :cascade do |t|
    t.string "rate", null: false
    t.string "kanji", null: false
    t.string "reading", null: false
    t.text "meaning_id", null: false
    t.text "description_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kanji"], name: "index_kanji_multiples_on_kanji", unique: true
    t.index ["rate"], name: "index_kanji_multiples_on_rate"
  end

  create_table "kanji_singles", force: :cascade do |t|
    t.string "rate", null: false
    t.string "kanji", null: false
    t.string "onyomi"
    t.string "kunyomi"
    t.text "meaning_id", null: false
    t.text "description_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kanji"], name: "index_kanji_singles_on_kanji", unique: true
    t.index ["rate"], name: "index_kanji_singles_on_rate"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "quiz_type", null: false
    t.string "kanji_type", null: false
    t.string "level", null: false
    t.integer "kanji_id", null: false
    t.boolean "correct", null: false
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "kanji_type"], name: "index_quiz_attempts_on_user_id_and_kanji_type"
    t.index ["user_id", "level"], name: "index_quiz_attempts_on_user_id_and_level"
    t.index ["user_id", "quiz_type"], name: "index_quiz_attempts_on_user_id_and_quiz_type"
    t.index ["user_id"], name: "index_quiz_attempts_on_user_id"
  end

  create_table "user_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "kanji_character_id", null: false
    t.boolean "is_correct"
    t.datetime "attempted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kanji_character_id"], name: "index_user_progresses_on_kanji_character_id"
    t.index ["user_id"], name: "index_user_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "exam_answers", "exam_attempts"
  add_foreign_key "exam_attempts", "users"
  add_foreign_key "quiz_attempts", "users"
  add_foreign_key "user_progresses", "kanji_characters"
  add_foreign_key "user_progresses", "users"
end
