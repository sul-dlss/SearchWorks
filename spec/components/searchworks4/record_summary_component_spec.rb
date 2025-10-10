# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::RecordSummaryComponent, type: :component do
  before do
    with_controller_class CatalogController do
      presenter = vc_test_controller.helpers.document_presenter(document)
      render_inline(described_class.new(presenter:))
    end
  end

  context 'with no authors' do
    let(:document) { SolrDocument.from_fixture('5488000.yml') }

    it "renders the description" do
      expect(page).to have_content "The gases of swamp rice soils"
      expect(page).to have_css "ul"
      expect(page).to have_no_content "ul li"
    end
  end

  context 'with a thumbnail' do
    let(:document) { SolrDocument.from_fixture('in00000053236.yml') }

    it "renders the thumbnail" do
      expect(page).to have_css ".document-thumbnail"
    end
  end

  context 'with main title dates' do
    context 'with a single year' do
      let(:document) { SolrDocument.new(id: 'x', pub_year_ss: '2020') }

      it "renders the date in parentheses" do
        expect(page).to have_text '(2020)'
      end
    end

    context 'with uncertain decade' do
      let(:document) { SolrDocument.new(id: 'x', pub_year_ss: '184u') }

      it "renders the date with 0s" do
        expect(page).to have_text '1840s'
      end
    end

    context 'with uncertain century' do
      let(:document) { SolrDocument.new(id: 'x', pub_year_ss: '18uu') }

      it "renders the date with 0s" do
        expect(page).to have_text '1800s'
      end
    end

    context 'with a date range' do
      let(:document) { SolrDocument.new(id: 'x', pub_year_ss: '200u - 201u') }

      it "renders the date range in parentheses" do
        expect(page).to have_text '(2000s - 2010s)'
      end
    end

    context 'with an open ended range' do
      let(:document) { SolrDocument.new(id: 'x', pub_year_ss: '201u - ') }

      it "renders the date range in parentheses" do
        expect(page).to have_text '(2010s - )'
      end
    end
  end
end
