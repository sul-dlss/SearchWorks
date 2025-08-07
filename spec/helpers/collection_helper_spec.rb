# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionHelper do
  describe "#collection_members_path" do
    let(:document) { instance_double(SolrDocument, id: '1234', prefixed_id: 'a1234') }

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
