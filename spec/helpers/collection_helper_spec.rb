# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionHelper do
  describe "#link_to_collection_members" do
    let(:document) { instance_double(SolrDocument, id: '1234', collection_id: 'a1234') }

    it "links to the given text" do
      expect(link_to_collection_members("LinkText", document)).to match /<a href.*>LinkText<\/a>/
    end
    it "links the collection id with prefix" do
      expect(link_to_collection_members("LinkText", document)).to match /<a href=\".*collection.*=a1234\".*/
    end
  end

  describe "#collections_search_params" do
    it "is the collection_type facet value of 'Digital Collection" do
      expect(collections_search_params).to have_key(:f)
      expect(collections_search_params[:f]).to have_key(:collection_type)
      expect(collections_search_params[:f][:collection_type]).to eq ["Digital Collection"]
    end
  end

  describe "#collection_members_path" do
    let(:document) { instance_double(SolrDocument, id: '1234', collection_id: 'a1234') }

    it "links the collection id with prefix" do
      expect(collection_members_path(document)).to match /.*collection.*=a1234.*/
    end
  end

  describe "#collection_breadcrumb_value" do
    it "returns the collection name when present" do
      allow(helper).to receive(:document_presenter).and_return(
        OpenStruct.new(heading: 'Title2')
      )
      document_list = [
        SolrDocument.new(collection: ['a12345', 'a54321'], collection_with_title: ['a12345 -|- Title1', 'a54321 -|- Title2'])
      ]
      assign(:response, OpenStruct.new(documents: document_list))
      expect(helper.send(:collection_breadcrumb_value, 'a54321')).to eq 'Title2'
    end
    it "returns the ID with the prefix if there is no @document_list" do
      assign(:response, OpenStruct.new(documents: []))
      expect(helper.send(:collection_breadcrumb_value, 'a54321')).to eq 'a54321'
    end
    it "returns the ID with the prefix if there are no matching collections" do
      document_list = [
        SolrDocument.new(collection: ['12345', '54321'], collection_with_title: ['12345 -|- Title1', '54321 -|- Title2'])
      ]
      assign(:response, OpenStruct.new(documents: document_list))
      expect(helper.send(:collection_breadcrumb_value, 'a11111')).to eq 'a11111'
    end
  end
end
