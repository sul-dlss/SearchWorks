# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsDocumentHelper do
  let(:blacklight_config) { CatalogController.blacklight_config }

  before(:all) do
    data_01 = {
      publication_year_isi: 1999,
      title_display: "Car : a drama of the American workplace",
      isbn_display: ["0393040801x", "9780393040807"],
      lccn: "a 96049953",
      oclc: 36024029
    }

    data_02 = {
      earliest_poss_year_isi: 1801,
      latest_poss_year_isi: 1837
    }

    data_03 = {
      pub_year_ss: '199 B.C.',
      earliest_poss_year_isi: -199,
      latest_poss_year_isi: -250
    }
    @document_01 = SolrDocument.new(data_01)
    @document_02 = SolrDocument.new(data_02)
    @document_03 = SolrDocument.new(data_03)
    @document_04 = SolrDocument.new
    @document_05 = SolrDocument.new(
      eds_publication_year: '2017'
    )
  end

  describe "Render metadata" do
    describe '#get_main_title_date' do
      it "should return date and date ranges" do
        expect(get_main_title_date(@document_01)).to eq "[1999]"
        expect(get_main_title_date(@document_02)).to eq "[1801 ... 1837]"
        expect(get_main_title_date(@document_03)).to eq "[199 B.C.]"
      end

      it 'returns the eds publication year when present' do
        expect(get_main_title_date(@document_05)).to eq '[2017]'
      end
    end

    it "should return book ids with prefixes" do
      book_ids = get_book_ids(@document_01)

      expect(book_ids['isbn']).to eq ["ISBN0393040801x", "ISBN9780393040807"]
      expect(book_ids['lccn']).to eq ["LCCNa96049953"]
      expect(book_ids['oclc']).to eq ["OCLC36024029"]
    end
  end
end
