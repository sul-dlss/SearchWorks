# frozen_string_literal: true

Specialist = Data.define(:name, :full_title, :research_areas, :description, :photo_url, :email, :types) do
  def self.stopwords
    %w[a an and are as at be by for from has have in is it of on or that the to with]
  end

  def self.tokenize(term)
    return unless term

    term.downcase.gsub("'s", 's').gsub(/[[:punct:]]/, ' ').split(/\s+/).excluding(stopwords)
  end

  def self.find(query)
    query_tokens = Specialist.tokenize(query)

    specialists.map { |specialist| [specialist, (specialist.search_tokens & query_tokens).map { |token| Specialist.idf[token] || 0 }.sum] }
               .filter { |_, score| score.positive? }.max_by { |_, score| score }&.first
  end

  def self.specialists
    @specialists ||= load_specialists
  end

  def self.load_specialists
    response = JSON.parse(Rails.root.join('config/subject_specialist.json').read)

    response['results'].filter_map do |data|
      specialist = Specialist.from_sws_json(data)

      specialist if specialist.subject_specialist?
    end
  end

  def self.from_sws_json(data)
    new(
      name: "#{data['firstName']} #{data['lastName']}",
      full_title: data['fullTitle'],
      research_areas: data['research'],
      photo_url: data.dig('photo', 'url'),
      email: data['email'],
      types: data['personTypes']&.pluck('name'),
      description: data['body']
    )
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
    (research_areas + [name, full_title]).flat_map do |x|
      Specialist.tokenize(x)
    end
  end

  def subject_specialist?
    types&.include?('Subject specialist')
  end
end
