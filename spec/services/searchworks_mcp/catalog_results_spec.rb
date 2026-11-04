# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::CatalogResults do
  let(:config) { Struct.new(:facet_fields).new({}) }

  def format(documents)
    response = Struct.new(:documents, :total, :facet_fields).new(documents, documents.length, {})
    described_class.format(response:, query: 'physics', search_field: 'all_fields', filters: {}, config:)
  end

  it 'requires an availability lookup when exactly one result is returned' do
    result = format([SolrDocument.new(id: '123', title_display: 'A book')])

    expect(result[:text]).to include('Required next step: Call get_availability with id 123')
    expect(result.dig(:structured_content, :results, 0, :availability_lookup)).to eq(
      tool: 'get_availability',
      id: '123',
      instruction: 'Call get_availability with this id before presenting this record to the user.'
    )
  end

  it 'requires an availability lookup for the selected result from a short list' do
    documents = [
      SolrDocument.new(id: '123', title_display: 'First book'),
      SolrDocument.new(id: '456', title_display: 'Second book')
    ]
    result = format(documents)

    expect(result[:text]).to include(
      "Required next step: After selecting the best result, call get_availability with that result's id"
    )
  end

  it 'does not add the directive to a longer result list' do
    documents = Array.new(6) { |index| SolrDocument.new(id: index.to_s, title_display: "Book #{index}") }

    expect(format(documents)[:text]).not_to include('Required next step')
  end

  it 'suggests a table when there are more than three results' do
    documents = Array.new(4) { |index| SolrDocument.new(id: index.to_s, title_display: "Book #{index}") }

    expect(format(documents)[:text]).to include('Display hint: Present these results to the user as a table')
  end

  it 'does not suggest a table for three or fewer results' do
    documents = Array.new(3) { |index| SolrDocument.new(id: index.to_s, title_display: "Book #{index}") }

    expect(format(documents)[:text]).not_to include('Display hint')
  end

  it 'includes highlighted snippets showing why each record matched' do
    solr_response = {
      'highlighting' => {
        '123' => { 'all_search' => ['For **2** **player** use.', 'Ages 8+, **2** **players**'] }
      }
    }
    result = format([SolrDocument.new({ id: '123', title_display: 'A game' }, solr_response)])

    expect(result.dig(:structured_content, :results, 0, :matched_text)).to eq(
      ['For **2** **player** use.', 'Ages 8+, **2** **players**']
    )
    expect(result[:text]).to include('Matched text: For **2** **player** use. … Ages 8+, **2** **players**')
  end

  it 'omits matched text when there is no highlighting' do
    result = format([SolrDocument.new(id: '123', title_display: 'A book')])

    expect(result.dig(:structured_content, :results, 0)).not_to have_key(:matched_text)
  end

  describe 'facets' do
    let(:config) do
      Struct.new(:facet_fields).new({ 'format_hsim' => Blacklight::Configuration::FacetField.new(key: 'format_hsim', field: 'format_hsim', label: 'Format') })
    end

    def response_with(documents, facet_fields)
      Struct.new(:documents, :total, :facet_fields).new(documents, documents.length, facet_fields)
    end

    it 'reports results and facets without filters when filters remove every result' do
      unfiltered = Struct.new(:documents, :total, :facet_fields).new([], 2994, { 'format_hsim' => ['Object', 2900, 'Book', 40] })
      result = described_class.format(response: response_with([], {}), query: 'board games', search_field: 'all_fields',
                                      filters: { 'format' => 'Equipment' }, config:, unfiltered_response: unfiltered)

      expect(result.dig(:structured_content, :without_filters)).to eq(
        total: 2994,
        facets: { 'format' => { label: 'Format', values: [{ value: 'Object', count: 2900 }, { value: 'Book', count: 40 }] } }
      )
      expect(result[:text]).to include('Without filters, this query has 2994 results', '- Format: Object (2900), Book (40)')
    end

    it 'omits the unfiltered summary when there is no fallback search' do
      result = described_class.format(response: response_with([], {}), query: 'board games', search_field: 'all_fields',
                                      filters: {}, config:)

      expect(result[:structured_content]).not_to have_key(:without_filters)
    end
  end
end
