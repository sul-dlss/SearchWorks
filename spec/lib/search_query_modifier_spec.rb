# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchQueryModifier do
  let(:default_config) { {} }
  let(:stopwords_query) { SearchQueryModifier.new(Blacklight::SearchState.new({ q: "And we have stopwords oF THE month", other: 'something' }, default_config)) }

  describe "fielded search" do
    let(:config) { OpenStruct.new(default_search_field: OpenStruct.new(field: 'search')) }
    let(:fielded_search) { SearchQueryModifier.new(Blacklight::SearchState.new({ search_field: "search_title", q: 'something', f: 'else' }, config)) }
    let(:no_query_search) { SearchQueryModifier.new(Blacklight::SearchState.new({ search_field: 'search_title' }, config)) }
    let(:no_fielded_search) { SearchQueryModifier.new(Blacklight::SearchState.new({ q: 'something' }, config)) }
    let(:default_fielded_search) { SearchQueryModifier.new(Blacklight::SearchState.new({ search_field: "search", q: 'something' }, config)) }

    describe "#fielded_search?" do
      it "should return true when a fielded search is selected" do
        expect(fielded_search.fielded_search?).to be_truthy
      end
      it "should return false when no field is selected (e.g. default)" do
        expect(no_fielded_search.fielded_search?).to be_falsey
      end
      it "should return false when there is no query (because no field searches are being done)" do
        expect(no_query_search.fielded_search?).to be_falsey
      end
      it "should return false when the default search field is present" do
        expect(default_fielded_search.fielded_search?).to be_falsey
      end
    end

    describe "#has_query?" do
      it "should return true when a search has a query" do
        expect(fielded_search.has_query?).to be_truthy
      end
      it "should return false when a search does not have a query" do
        expect(no_query_search.has_query?).to be_falsey
      end
    end

    describe "#params_without_fielded_search" do
      it "should return the parameters w/o the search_field param" do
        expect(fielded_search.params_without_fielded_search[:q]).to eq 'something'
        expect(fielded_search.params_without_fielded_search[:search_field]).not_to be_present
      end
    end

    describe "#params_without_fielded_search_and_filters" do
      it "should return the parameters w/o the search_field param or filters" do
        expect(fielded_search.params_without_fielded_search_and_filters[:search_field]).not_to be_present
        # expect(fielded_search.params_without_fielded_search[:f]).to_not be present
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
    let(:filtered_search) { SearchQueryModifier.new(Blacklight::SearchState.new({ f: { 'fieldA' => ['Something'], 'fieldB' => ['Something Else'] }, q: 'something' }, facet_config)) }
    let(:ranged_search) { SearchQueryModifier.new(Blacklight::SearchState.new({ range: { 'range_field' => { 'begin' => '1234', 'end' => '4321' } }, q: 'something' }, facet_config)) }
    let(:no_filter_search) { SearchQueryModifier.new(Blacklight::SearchState.new({ q: 'something' }, default_config)) }

    describe "#has_filters?" do
      it "should return true when a search has filters" do
        expect(filtered_search.has_filters?).to be_truthy
      end
      it "should return true when there is a range" do
        expect(ranged_search.has_filters?).to be_truthy
      end
      it "should return false when a search has no filters" do
        expect(no_filter_search.has_filters?).to be_falsey
      end
    end

    describe "#params_without_filters" do
      it "should return the parameters hash without an f param" do
        expect(filtered_search.params_without_fielded_search[:q]).to eq 'something'
        expect(filtered_search.params_without_filters[:f]).not_to be_present
      end
      it "should return the parameters hash without a range param" do
        expect(ranged_search.params_without_fielded_search[:q]).to eq 'something'
        expect(ranged_search.params_without_filters[:range]).not_to be_present
      end
    end
  end
end
