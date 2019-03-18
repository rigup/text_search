class Parent < ActiveRecord::Base
  include TextSearch
  has_many :children

  text_search_scope :no_children, against: [:value_1, :value_2]

  text_search_scope :children_equal, associated_against: {
      children: [:value_1, :value_2]
  }

  text_search_scope :highlight_equal, associated_against: {
      children: [:value_1, :value_2]
  }, highlight: true

  text_search_scope :highlight_unequal, associated_against: {
      children: {
          value_1: 1,
          value_2: 2,
      }
  }, highlight: true

  scope :english_no_stop_words, -> {
    ActiveRecord::Base.connection.execute('
      CREATE TEXT SEARCH DICTIONARY english_no_stop_words (TEMPLATE = pg_catalog.english_stem);
      CREATE TEXT SEARCH CONFIGURATION english_no_stop_words (PARSER = default);
      ALTER TEXT SEARCH CONFIGURATION english_no_stop_words
        ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, hword, hword_part, word WITH english_no_stop_words;'
    );
  }
end