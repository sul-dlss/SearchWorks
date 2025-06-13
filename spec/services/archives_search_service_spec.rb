# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArchivesSearchService do
  subject(:service) { described_class.new }

  let(:response) do
    Rails.root.join('spec/fixtures/archives.json').read
  end
  let(:query) { 'my query' }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  describe '#search' do
    subject(:search) { service.search(query) }

    let(:first_result) { search.results.first }

    it 'sets the attributes' do
      aggregate_failures do
        expect(first_result.title).to eq 'Poetry Now v.6 n.4'
        expect(first_result.physical).to eq 'File'
        expect(first_result.icon).to eq 'file.svg'
        expect(first_result.link).to eq 'https://archives.stanford.edu/catalog/m1136_aspace_6c625d4af28bacf807b51eca39d07ebe'
        expect(first_result.description).to eq "POETRY NOW #34\t1982\tDAVID RAY ISSUE"
      end
    end
  end
end
