# frozen_string_literal: true

class Specialist < Data.define(:title, :research_areas, :photo_url, :email)
  def self.find(query)
    specialists.find { |specialist| specialist.research_areas.any? { |area| area.downcase.include?(query.downcase) } }
  end

  def self.specialists
    @specialists ||= load_specialists
  end

  def self.load_specialists
    Rails.root.join('config/subject_specialist.jsonl').readlines.filter_map do |line|
      data = JSON.parse(line).slice('title', 'researchAreas', 'photoUrl', 'email').transform_keys(&:underscore).symbolize_keys
      next if data[:research_areas] == '$undefined'

      Specialist.new(**data)
    end
  end
end
