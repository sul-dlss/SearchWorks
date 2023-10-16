require 'rails_helper'
require 'fixtures_indexer'

RSpec.describe FixturesIndexer do
  let(:stub_solr) { double('solr', uri: URI.parse('http://localhost:8983/solr/blacklight-core')) }

  before do
    allow(Blacklight.default_index).to receive(:connection).at_least(1).times.and_return(stub_solr)
  end

  describe "run" do
    it "should index the fixtures and commit them" do
      expect(stub_solr).to receive(:add).twice.and_return(true)
      expect(stub_solr).to receive(:commit).twice.and_return(true)
      FixturesIndexer.run
      subject.run
    end
  end

  describe "#new" do
    it "should set the solr client" do
      expect(FixturesIndexer.new.instance_variable_get("@solr")).to eq stub_solr
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

  context 'when trying to index to something other than what is configured in the solr_wraper.yml' do
    before do
      allow_any_instance_of(described_class).to receive(:configured_blacklight_collection).and_return('might-be-prod')
    end

    it 'raises an error' do
      expect do
        subject.run
      end.to raise_error(
        ArgumentError,
        a_string_including('You are trying to index to the "might-be-prod" collection')
      )
    end
  end
end
