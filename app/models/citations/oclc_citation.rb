# frozen_string_literal: true

###
# Returns an OCLC citation formatted for use by SearchWorks
module Citations
  class OclcCitation
    CITATION_STYLES = %w[apa
                         chicago-author-date
                         harvard-cite-them-right
                         modern-language-association
                         turabian-author-date].freeze

    attr_reader :oclc_numbers

    # @param oclc_numbers [Array<String>] An array of OCLC numbers
    def initialize(oclc_numbers:)
      @oclc_numbers = oclc_numbers
    end

    # @return [Hash] A hash with OCLC numbers as keys and hashes of citation styles and citation texts as values.
    #                The keys are OCLC numbers so we can fetch citations in bulk and look up the citation by OCLC number.
    def citations_by_oclc_number
      return {} unless Settings.oclc_discovery.citations.enabled

      @citations_by_oclc_number ||= group_citations_by_oclc_number
    end

    private

    # Transforms one or more OCLC Citation responses and groups the response entries by OCLC number
    # transforms data from: [{ oclcNumber: oclc_number, entries: [{ style: citation_style, citationText: citation_text }] }]
    # to data like: { oclc_number => { citation_style => citation_text } }
    def group_citations_by_oclc_number
      grouped_citations = oclc_citations.flat_map { |citation| citation['entries'] }.group_by { |citation| citation['oclcNumber'] }
      transform_grouped_citations(grouped_citations)
    end

    # Transforms a hash of grouped citation responses into a hash of citation styles and citation texts
    # transforms data from: { oclc_number => [{ style: citation_style, citationText: citation_text }] }
    # into data like: { oclc_number => { citation_style => citation_text } }
    def transform_grouped_citations(grouped_citations)
      grouped_citations.transform_values do |citations|
        citations.to_h { |citation| [searchworks_style_code(citation['style']), citation['citationText']&.html_safe] } # rubocop:disable Rails/OutputSafety
      end
    end

    def oclc_citations
      CITATION_STYLES.flat_map do |citation_style|
        Thread.new { oclc_client.citations(oclc_numbers:, citation_style:) }
      end.flat_map(&:value)
    end

    def oclc_client
      @oclc_client ||= OclcDiscoveryClient.new
    end

    def searchworks_style_code(oclc_style_code)
      case oclc_style_code
      when 'chicago-author-date'
        'chicago'
      when 'harvard-cite-them-right'
        'harvard'
      when 'modern-language-association'
        'mla'
      when 'turabian-author-date'
        'turabian'
      else
        oclc_style_code
      end
    end
  end
end
