# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectionFilterQuery do
  subject(:collection_filter_query) { described_class.call({}, search_state.filter('collection'), {}) }

  let(:params) { { f: { collection: collection_id } } }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_facet_field "collection", filter_query_builder: described_class
    end
  end
  let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, blacklight_config, double) }

  context "when collection has a leading a" do
    let(:collection_id) { 'a123456' }

    it "creates an OR query" do
      expect(collection_filter_query).to eq 'collection: (123456 OR a123456)'
    end
  end

  context "when a collection does not have a leading a" do
    let(:collection_id) { '123456' }

    it "creates an OR query" do
      expect(collection_filter_query).to eq 'collection: (123456 OR a123456)'
    end
  end

  context "when collection has a leading in" do
    let(:collection_id) { 'in123456' }

    it "creates a single query" do
      expect(collection_filter_query).to eq 'collection: in123456'
    end
  end

  context "when a collection has a leading L" do
    let(:collection_id) { 'L123456' }

    it "creates a single query" do
      expect(collection_filter_query).to eq 'collection: L123456'
    end
  end
end
