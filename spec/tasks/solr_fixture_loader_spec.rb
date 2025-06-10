# frozen_string_literal: true

require 'rails_helper'
require 'solr_fixture_loader'

RSpec.describe SolrFixtureLoader do
  describe ".load" do
    it "returns an array" do
      file = described_class.file_list.first
      expect(described_class.load(File.basename(file))).to be_a Hash
    end
  end

  describe ".file_list" do
    it "is an array" do
      expect(described_class.file_list).to be_an Array
    end

    it "is an array of fixture file references" do
      expect(described_class.file_list).to all(match(%r{/fixtures/solr_documents/.*\.yml$}))
    end
  end

  describe ".load_all" do
    it "returns an array of solr documents" do
      docs = described_class.load_all
      expect(docs).to be_an Array
      expect(docs).to all(be_a(Hash).and(have_key('id')))
    end
  end
end
