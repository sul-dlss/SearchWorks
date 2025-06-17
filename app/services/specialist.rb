# frozen_string_literal: true

Specialist = Data.define(:title, :full_title, :research_areas, :photo_url, :email) do
  def self.tokenize(term)
    term.downcase.gsub(/[[:punct:]]/, ' ').split(/\s+/)
  end

  def self.find(query)
    query_tokens = Specialist.tokenize(query)

    specialists.shuffle.max_by { |specialist| (specialist.search_tokens & query_tokens).map { |token| Specialist.idf[token] || 0 }.sum }
  end

  def self.specialists
    @specialists ||= load_specialists
  end

  def self.load_specialists
    Rails.root.join('config/subject_specialist.jsonl').readlines.filter_map do |line|
      data = JSON.parse(line).slice('title', 'fullTitle', 'researchAreas', 'photoUrl', 'email').transform_keys(&:underscore).symbolize_keys
      next if data[:research_areas] == '$undefined'

      Specialist.new(**data)
    end
  end

  # calculates the inverse document frequency (IDF) for each token across all specialists, which can then be used for scoring partial matches
  # that weight the less common tokens more heavily
  def self.idf
    @idf ||= begin
      specialist_count = specialists.count.to_f

      token_counts = specialists.each_with_object({}) do |specialist, hash|
        specialist.search_tokens.uniq.each do |token|
          hash[token] ||= 0
          hash[token] += 1
        end
      end

      token_counts.transform_values do |term_count|
        Math.log10(specialist_count / term_count)
      end
    end
  end

  def search_tokens
    (research_areas + [title, full_title]).flat_map do |x|
      Specialist.tokenize(x)
    end
  end
end
