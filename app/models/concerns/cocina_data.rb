# frozen_string_literal: true

module CocinaData
  extend ActiveSupport::Concern

  def cocina?
    cocina_json_str.present?
  end

  def cocina_json_str
    self[:cocina_struct]&.first
  end

  def cocina
    @cocina ||= JSON.parse(cocina_json_str)
  end

  def cocina_display
    @cocina_display ||= CocinaDisplay::CocinaRecord.from_json(cocina_json_str) if cocina?
  end
end
