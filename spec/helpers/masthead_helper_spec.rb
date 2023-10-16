require 'rails_helper'
require 'page_location'

RSpec.describe MastheadHelper do
  describe "#render_masthead_partial" do
    let(:page_location) { PageLocation.new(search_state) }
    let(:search_state) { instance_double(Blacklight::SearchState) }

    before { allow(helper).to receive(:page_location).and_return(page_location) }

    it "renders partials that exist" do
      allow(page_location).to receive(:access_point).and_return("databases")
      expect(helper).to receive(:render).with("catalog/mastheads/databases", {}).and_return('databases-partial')
      expect(render_masthead_partial).to eq "databases-partial"
    end

    it "is empty for access points that don't have mastheads" do
      allow(page_location).to receive(:access_point).and_return("not_an_access_point")
      expect(render_masthead_partial).to eq ''
    end
  end

  describe "#facets_prefix_options" do
    it "should have the correct number of elements" do
      expect(facets_prefix_options.length).to eq 27
    end
    it "should include the necessary options" do
      expect(facets_prefix_options).to include "0-9"
      expect(facets_prefix_options).to include "A"
      expect(facets_prefix_options).to include "X"
      expect(facets_prefix_options).to include "Z"
    end
  end

  describe '#digital_collections_params_for' do
    it 'should always include "Stanford Digital Repository" in the building facet' do
      expect(digital_collections_params_for).to match /building_facet.*Stanford\+Digital\+Repository/
      expect(digital_collections_params_for('something')).to match /building_facet.*Stanford\+Digital\+Repository/
    end
    it 'should include the given parameter as the format_main_ssim' do
      expect(digital_collections_params_for).not_to match /format_main_ssim/
      expect(digital_collections_params_for('something')).to match /format_main_ssim.*something/
    end
  end

  describe 'bookplate_from_document_list' do
    it 'is nil when the correct facet field is not present' do
      expect(helper).to receive(:params).at_least(:once).and_return({})
      expect(helper.bookplate_from_document_list).to be_nil
    end

    it 'is nil when there is no bookplate in the first solr document' do
      response = double('SolrResponse', docs: [SolrDocument.new])
      expect(helper).to receive(:params).at_least(:once).and_return(
        f: { fund_facet: ['ABC123'] }
      )

      expect(helper.bookplate_from_document_list(response)).to be_nil
    end

    it 'returns the bookplate that matches the value in the fund_facet' do
      response = double('SolrResponse', docs: [
        SolrDocument.new(
          bookplates_display: [
            'FUND321 -|- druid:xyz321',
            'FUND123 -|- druid:abc123'
          ]
        )
      ])
      expect(helper).to receive(:params).at_least(:once).and_return(
        f: { fund_facet: ['abc123'] }
      )

      bookplate = helper.bookplate_from_document_list(response)
      expect(bookplate).to be_a Bookplate
      expect(bookplate.send(:fund_name)).to eq 'FUND123'
      expect(bookplate.send(:druid)).to eq 'abc123'
    end
  end

  describe 'bookplate_breadcrumb_value' do
    it 'returns the given fund name if there are no documents' do
      response = double('SolrResponse', docs: [])
      expect(bookplate_breadcrumb_value('ABC123', response)).to eq 'ABC123'
    end

    it 'returns the given fund name if there is no matching bookplate' do
      response = double('SolrResponse', docs: [SolrDocument.new])
      expect(helper).to receive(:bookplate_from_document_list).and_return(nil)
      expect(helper.bookplate_breadcrumb_value('ABC123', response)).to eq 'ABC123'
    end

    it 'returns the bookplate text when a matching bookplate is available' do
      response = double('SolrResponse', docs: [SolrDocument.new])
      expect(helper).to receive(:bookplate_from_document_list).and_return(
        double('Bookplate', text: 'Bookplate-text')
      )
      expect(helper.bookplate_breadcrumb_value('ABC123', response)).to eq 'Bookplate-text'
    end
  end

  describe "#page_location" do
    before do
      allow(view).to receive(:search_state).and_return(instance_double(Blacklight::SearchState))
    end

    it "returns a PageLocation" do
      expect(helper.page_location).to be_a PageLocation
    end
  end
end
