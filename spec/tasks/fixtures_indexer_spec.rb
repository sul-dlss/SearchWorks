require 'spec_helper'
require 'fixtures_indexer'

describe FixturesIndexer do
  describe "#new" do
    it "should set the solr client" do
      expect(FixturesIndexer.new.instance_variable_get("@solr")).to be_a RSolr::Client
    end
  end
  describe "#fixtures" do
    it "should be an array" do
      expect(subject.fixtures).to be_an Array
    end
    it "should be an array of solr document hashes" do
      subject.fixtures.each do |fixture|
        expect(fixture).to be_a Hash
        expect(fixture).to have_key :id
      end
    end
  end
  describe "#file_list" do
    it "should be an array" do
      expect(subject.file_list).to be_an Array
    end
    it "should be an array of fixture file references" do
      subject.file_list.each do |file|
        expect(file).to match /\/fixtures\/solr_documents\/.*.yml$/
      end
    end
  end
end
