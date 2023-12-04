# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogSearchService do
  subject(:service) { described_class.new }

  let(:response) { JSON.dump({ response: { docs: [] } }) }
  let(:query) { CatalogSearchService::Request.new('my query') }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(service).to be_an AbstractSearchService }

  describe 'Response' do
    it { expect(service.search(query)).to be_an CatalogSearchService::Response }

    describe '#additional_facet_details' do
      before do
        expect_any_instance_of(CatalogSearchService::Response).to receive(:facets).at_least(:once).and_return(facet_data)
      end

      let(:addl_facet_details) { service.search(query).additional_facet_details('blah') }

      context 'when the facet data is present' do
        let(:facet_data) { [{ 'name' => 'format_main_ssim', 'items' => [{ 'label' => 'Database', 'hits' => 123 }] }] }

        it 'has hits returned from the facet' do
          expect(addl_facet_details.hits).to eq 123
        end

        it 'has a href that links to the full query' do
          expect(addl_facet_details.href).to include('/?q=blah&f[format_main_ssim][]=Database')
        end
      end

      context 'when the facet does not have any hits' do
        let(:facet_data) { [{ 'name' => 'format_main_ssim', 'items' => [{ 'label' => 'Database', 'hits' => '0' }] }] }

        it { expect(addl_facet_details).to be_nil }
      end

      context 'when the facet does not exist in the response' do
        let(:facet_data) { [] }

        it { expect(addl_facet_details).to be_nil }
      end
    end
  end
end
