# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsDocumentHelper do
  describe "Render metadata" do
    let(:document) do
      SolrDocument.new(
        publication_year_isi: 1999,
        pub_year_ss: '1999',
        title_display: "Car : a drama of the American workplace",
        isbn_display: ["0393040801x", "9780393040807"],
        lccn: "a 96049953",
        oclc: 36024029
      )
    end

    it "returns book ids with prefixes" do
      book_ids = get_book_ids(document)

      expect(book_ids['isbn']).to eq ["ISBN0393040801x", "ISBN9780393040807"]
      expect(book_ids['lccn']).to eq ["LCCNa96049953"]
      expect(book_ids['oclc']).to eq ["OCLC36024029"]
    end
  end
end
