# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
KanjiCharacter.destroy_all

# N5 Level Kanji
n5_kanjis = [
  { character: "人", meaning: "person", reading: "jin/nin/hito", level: "N5" },
  { character: "日", meaning: "day", reading: "nichi/jitsu/hi", level: "N5" },
  { character: "本", meaning: "book", reading: "hon/moto", level: "N5" },
  { character: "中", meaning: "middle", reading: "chuu/naka", level: "N5" },
  { character: "大", meaning: "big", reading: "dai/oo", level: "N5" },
  { character: "小", meaning: "small", reading: "shou/chii", level: "N5" },
  { character: "山", meaning: "mountain", reading: "san/yama", level: "N5" },
  { character: "川", meaning: "river", reading: "sen/kawa", level: "N5" },
  { character: "火", meaning: "fire", reading: "ka/hi", level: "N5" },
  { character: "水", meaning: "water", reading: "sui/mizu", level: "N5" },
  { character: "木", meaning: "tree", reading: "moku/ki", level: "N5" },
  { character: "金", meaning: "gold", reading: "kin/kane", level: "N5" },
  { character: "土", meaning: "earth", reading: "do/tsuchi", level: "N5" },
  { character: "子", meaning: "child", reading: "shi/ko", level: "N5" },
  { character: "女", meaning: "woman", reading: "jo/onna", level: "N5" },
  { character: "男", meaning: "man", reading: "dan/otoko", level: "N5" },
  { character: "車", meaning: "car", reading: "sha/kuruma", level: "N5" },
  { character: "学", meaning: "study", reading: "gaku/mana", level: "N5" },
  { character: "生", meaning: "life", reading: "sei/i", level: "N5" },
  { character: "先", meaning: "before", reading: "sen/saki", level: "N5" }
]

# N4 Level Kanji
n4_kanjis = [
  { character: "会", meaning: "meet", reading: "kai/a", level: "N4" },
  { character: "社", meaning: "company", reading: "sha/yashiro", level: "N4" },
  { character: "自", meaning: "self", reading: "ji/mizuka", level: "N4" },
  { character: "分", meaning: "minute", reading: "fun/wa", level: "N4" },
  { character: "新", meaning: "new", reading: "shin/atara", level: "N4" },
  { character: "場", meaning: "place", reading: "jou/ba", level: "N4" },
  { character: "部", meaning: "part", reading: "bu/be", level: "N4" },
  { character: "事", meaning: "matter", reading: "ji/koto", level: "N4" },
  { character: "手", meaning: "hand", reading: "shu/te", level: "N4" },
  { character: "数", meaning: "number", reading: "suu/kazu", level: "N4" },
  { character: "多", meaning: "many", reading: "ta/oo", level: "N4" },
  { character: "少", meaning: "few", reading: "shou/suku", level: "N4" },
  { character: "世", meaning: "world", reading: "sei/yo", level: "N4" },
  { character: "主", meaning: "main", reading: "shu/nushi", level: "N4" },
  { character: "取", meaning: "take", reading: "shu/to", level: "N4" },
  { character: "最", meaning: "most", reading: "sai/motto", level: "N4" },
  { character: "心", meaning: "heart", reading: "shin/kokoro", level: "N4" },
  { character: "開", meaning: "open", reading: "kai/hira", level: "N4" },
  { character: "思", meaning: "think", reading: "shi/omo", level: "N4" },
  { character: "家", meaning: "house", reading: "ka/ie", level: "N4" }
]

# N3 Level Kanji
n3_kanjis = [
  { character: "政", meaning: "politics", reading: "sei/masa", level: "N3" },
  { character: "経", meaning: "economy", reading: "kei/he", level: "N3" },
  { character: "済", meaning: "complete", reading: "sai/su", level: "N3" },
  { character: "民", meaning: "people", reading: "min/tami", level: "N3" },
  { character: "連", meaning: "connect", reading: "ren/tsura", level: "N3" },
  { character: "対", meaning: "opposite", reading: "tai/tsui", level: "N3" },
  { character: "部", meaning: "department", reading: "bu", level: "N3" },
  { character: "法", meaning: "law", reading: "hou/nori", level: "N3" },
  { character: "現", meaning: "present", reading: "gen/arawa", level: "N3" },
  { character: "地", meaning: "ground", reading: "chi/ji", level: "N3" },
  { character: "方", meaning: "direction", reading: "hou/kata", level: "N3" },
  { character: "期", meaning: "period", reading: "ki/go", level: "N3" },
  { character: "発", meaning: "emit", reading: "hatsu/ta", level: "N3" },
  { character: "表", meaning: "surface", reading: "hyou/omote", level: "N3" },
  { character: "情", meaning: "emotion", reading: "jou/nasa", level: "N3" },
  { character: "変", meaning: "change", reading: "hen/ka", level: "N3" },
  { character: "体", meaning: "body", reading: "tai/karada", level: "N3" },
  { character: "的", meaning: "target", reading: "teki/mato", level: "N3" },
  { character: "質", meaning: "quality", reading: "shitsu", level: "N3" },
  { character: "問", meaning: "question", reading: "mon/to", level: "N3" }
]

# Create all kanji (use find_or_create_by to avoid duplicates)
all_kanjis = n5_kanjis + n4_kanjis + n3_kanjis

all_kanjis.each do |kanji_data|
  KanjiCharacter.find_or_create_by(character: kanji_data[:character]) do |kanji|
    kanji.meaning = kanji_data[:meaning]
    kanji.reading = kanji_data[:reading]
    kanji.level = kanji_data[:level]
  end
end

puts "Total kanji in database: #{KanjiCharacter.count}"
puts "N5: #{KanjiCharacter.by_level('N5').count}"
puts "N4: #{KanjiCharacter.by_level('N4').count}"
puts "N3: #{KanjiCharacter.by_level('N3').count}"
