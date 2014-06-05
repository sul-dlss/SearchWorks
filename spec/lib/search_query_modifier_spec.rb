require "spec_helper"

describe SearchQueryModifier do
  let(:default_config) { {} }
  describe "stopwords" do
    let(:stopwords_query) { SearchQueryModifier.new({q: "And we have stopwords oF THE month", other: 'something'}, default_config) }
    let(:no_stopwords_query) { SearchQueryModifier.new({q: "This query does not have stopwords", other: 'something'}, default_config) }
    describe "#params_without_stopwords" do
      it "should replace the 'q' parameter in the options with one that doesn't contain stopwords" do
        expect(stopwords_query.params_without_stopwords).to eq({q: "we have stopwords month", other: 'something'})
      end
    end
    describe "#query_has_stopwords?" do
      it "should return true when a query contains stopwords" do
        expect(stopwords_query.query_has_stopwords?).to be_true
      end
      it "should return false when a query does not contain stopwords" do
        expect(no_stopwords_query.query_has_stopwords?).to be_false
      end
    end
  end
  describe "fielded search" do
    let(:config) { OpenStruct.new(default_search_field: OpenStruct.new(field: 'search') ) }
    let(:fielded_search) { SearchQueryModifier.new({search_field: "search_title", q: 'something'}, config) }
    let(:no_query_search) { SearchQueryModifier.new({search_field: 'search_title'}, config) }
    let(:no_fielded_search) { SearchQueryModifier.new({q: 'something'}, config) }
    let(:default_fielded_search) { SearchQueryModifier.new({search_field: "search", q: 'something'}, config) }
    describe "#fielded_search?" do
      it "should return true when a fielded search is selected" do
        expect(fielded_search.fielded_search?).to be_true
      end
      it "should return false when no field is selected (e.g. default)" do
        expect(no_fielded_search.fielded_search?).to be_false
      end
      it "should return false when there is no query (because no field searches are being done)" do
        expect(no_query_search.fielded_search?).to be_false
      end
      it "should return false when the default search field is present" do
        expect(default_fielded_search.fielded_search?).to be_false
      end
    end
    describe "#params_without_fielded_search" do
      it "should return the parameters w/o the search_field param" do
        expect(fielded_search.params_without_fielded_search[:q]).to eq 'something'
        expect(fielded_search.params_without_fielded_search[:search_field]).to_not be_present
      end
    end
  end
  describe "filtered search" do
    let(:facet_config) {
      Blacklight::Configuration.new do |config|
        config.add_facet_field 'fieldA', label: "A field"
        config.add_facet_field 'fieldB', label: 'Another field'
      end
    }
    let(:filtered_search) { SearchQueryModifier.new({f: {'fieldA' => 'Something', 'fieldB' => 'Something Else'}, q: 'something'}, facet_config) }
    let(:no_filter_search) { SearchQueryModifier.new({q: 'something'}, default_config) }
    describe "#has_filters?" do
      it "should return true when a search has filters" do
        expect(filtered_search.has_filters?).to be_true
      end
      it "should return false when a search has no filters" do
        expect(no_filter_search.has_filters?).to be_false
      end
    end
    describe "#params_without_filters" do
      it "should return the parameters hash without an f param" do
        expect(filtered_search.params_without_fielded_search[:q]).to eq 'something'
        expect(filtered_search.params_without_filters[:f]).to_not be_present
      end
    end
    describe "#selected_filter_labels" do
      it "should return labels as a string" do
        expect(filtered_search.selected_filter_labels).to eq "A field, Another field"
      end
    end
  end
end
