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
end
