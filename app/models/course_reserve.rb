# frozen_string_literal: true

# The store of course reserve data from Folio
class CourseReserve < ApplicationRecord
  serialize :instructors, coder: YAML, type: Array
  validates :id, presence: true
  self.primary_key = 'id'
end
