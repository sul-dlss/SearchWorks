# frozen_string_literal: true

###
# Citation is a simple class that takes a Hash like object (SolrDocument)
# and returns a hash of citations for the configured formats
class Citation
  def initialize(document, formats = [])
    @document = document
    @formats = formats
  end

  def citable?
    field.present? || citations_from_mods.present? || citations_from_eds.present?
  end

  def citations
    return null_citation if return_null_citation?
    return all_citations if all_formats_requested?

    all_citations.select do |format, _|
      desired_formats.include?(format)
    end
  end

  def api_url
    "#{base_url}/#{field}?cformat=all&wskey=#{api_key}"
  end

  class << self
    def grouped_citations(all_citations)
      citations = all_citations.each_with_object({}) do |cites, hash|
        cites.each do |format, citation|
          hash[format] ||= []
          hash[format] << citation
        end
      end
      # Append preferred citations to front of hash
      citations = {
        preferred_citation_key => citations[preferred_citation_key]
      }.merge(citations.except(preferred_citation_key)) if citations[preferred_citation_key]
      citations
    end

    def preferred_citation_key
      'PREFERRED CITATION'
    end

    # This being a valid test URL is predicated on the fact
    # that passing no OCLC number to the citations API responds successfully
    def test_api_url
      new(SolrDocument.new).api_url
    end
  end

  private

  attr_reader :document, :formats

  def return_null_citation?
    all_citations.blank? || (field.blank? && all_citations.blank?)
  end

  def element_is_citation?(element)
    element.attributes &&
      element.attributes['class'] &&
      element.attributes['class'].value =~ /^citation_style_/i
  end

  def all_formats_requested?
    desired_formats == ['ALL']
  end

  def all_citations
    @all_citations ||= begin
      citation_hash = {}
      if citations_from_mods.present?
        citation_hash[self.class.preferred_citation_key] = "<p>#{citations_from_mods}</p>".html_safe
      end

      citation_hash.merge!(citations_from_eds) if citations_from_eds.present?

      citation_hash.merge!(citations_from_oclc_response) if field.present?
      citation_hash
    end
  end

  def citations_from_oclc_response
    Nokogiri::HTML(response).css('p').each_with_object({}) do |element, hash|
      next unless element_is_citation?(element)

      element.attributes['class'].value[/^citation_style_(.*)$/i]
      hash[Regexp.last_match[1].upcase] = element.to_html.html_safe
    end
  end

  def citations_from_mods
    return unless document.mods && document.mods.note.present?

    document.mods.note.find do |note|
      note.label.downcase =~ /preferred citation:?/
    end.try(:values).try(:join)
  end

  def citations_from_eds
    return unless document.eds? && document['eds_citation_styles'].present?

    document['eds_citation_styles'].each_with_object({}) do |citation, hash|
      next unless citation['id'] && citation['data']

      hash[citation['id'].upcase] = citation['data'].html_safe
    end
  end

  def response
    @response ||= begin
      Faraday.get(api_url).body
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      Rails.logger.warn("HTTP GET for #{api_url} failed with #{e}")
      ''
    end
  end

  def field
    Array(document[config.DOCUMENT_FIELD]).try(:first)
  end

  def desired_formats
    return config.CITATION_FORMATS.map(&:upcase) unless formats.present?

    formats.map(&:upcase)
  end

  def base_url
    config.BASE_URL
  end

  def api_key
    config.API_KEY
  end

  def config
    Settings.OCLC
  end

  def null_citation
    { 'NULL' => '<p>No citation available for this record</p>'.html_safe }
  end
end
