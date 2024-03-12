# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/record/_marc_bibliographic" do
  include MarcMetadataFixtures

  describe "MARC 592" do
    let(:document) { SolrDocument.new(marc_json_struct: marc_592_fixture) }

    before do
      assign(:document, document)
    end

    it "should display for databases" do
      allow(document).to receive(:is_a_database?).and_return(true)
      render
      expect(rendered).to have_css("dt", text: "Note")
      expect(rendered).to have_css("dd", text: "A local note added to subjects only")
    end
    it "should not display for non-databases" do
      allow(document).to receive(:is_a_database?).and_return(false)
      render
      expect(rendered).to have_no_css("dt", text: "Note")
      expect(rendered).to have_no_css("dd", text: "A local note added to subjects only")
    end
  end

  describe "dates from solr" do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: metadata1, publication_year_isi: '1234', other_year_isi: '4321', copyright_year_isi: '5678'))
      render
    end

    it "should include dates from solr" do
      expect(rendered).to have_css('dt', text: 'Publication date')
      expect(rendered).to have_css('dd', text: '1234')

      expect(rendered).to have_css('dt', text: 'Date')
      expect(rendered).to have_css('dd', text: '4321')

      expect(rendered).to have_css('dt', text: 'Copyright date')
      expect(rendered).to have_css('dd', text: '5678')
    end
  end

  describe 'Related works' do
    before do
      assign(:document, SolrDocument.new(marc_json_struct: contributed_works_fixture))
      render
    end

    it 'should include the related works section' do
      expect(rendered).to have_css('dt', text: 'Related Work')
      expect(rendered).to have_css('dd a', text: '700 with t 700 $e Title.')
      expect(rendered).to have_no_css('dt', text: 'Included Work')
      expect(rendered).to have_no_css('dt', text: 'Contributor')
    end
  end
end
