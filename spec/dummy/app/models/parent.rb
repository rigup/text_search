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
end