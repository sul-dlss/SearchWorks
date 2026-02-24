# frozen_string_literal: true

module CocinaData
  extend ActiveSupport::Concern

  def cocina?
    self[:cocina_struct].present?
  end

  def cocina_display
    return nil unless cocina?

    @cocina_display ||= CocinaDisplay::CocinaRecord.from_json(self[:cocina_struct].first)
  end
end
