require "spec_helper"

def blacklight_config
  CatalogController.blacklight_config
end

describe ResultsDocumentHelper do

  before(:all) do
    data_01 = {
      :publication_year_isi => 1999,
      :title_display => "Car : a drama of the American workplace",
      :isbn_display => [ "0393040801", "9780393040807" ],
      :lccn => "96049953",
      :oclc => "36024029"
    }

    data_02 = {
      :earliest_poss_year_isi => 1801,
      :latest_poss_year_isi => 1837
    }

    @document_01 = SolrDocument.new(data_01)
    @document_02 = SolrDocument.new(data_02)

  end

  describe "Render metadata" do
    it "should return main title" do
      expect(get_main_title(@document_01)).to eq "Car : a drama of the American workplace"
    end

    it "should return date and date ranges" do
      expect(get_main_title_date(@document_01)).to eq "[1999]"
      expect(get_main_title_date(@document_02)).to eq "[1801 ... 1837]"
    end

    it "should return book ids with prefixes" do
      book_ids = get_book_ids(@document_01)

      expect(book_ids['isbn']).to eq ["ISBN0393040801", "ISBN9780393040807"]
      expect(book_ids['lccn']).to eq ["LCCN96049953"]
      expect(book_ids['oclc']).to eq ["OCLC36024029"]
    end

  end

end
