require 'spec_helper'

RSpec.describe Eds::Repository do
  let(:blacklight_config) {
    instance_double(Blacklight::Configuration,
      response_model: Blacklight::Solr::Response,
      document_model: SolrDocument
    )
  }
  subject(:instance) { described_class.new(blacklight_config) }

  it 'has the right methods' do
    expect(instance.respond_to?(:search)).to be_truthy
    expect(instance.respond_to?(:find)).to be_truthy
  end

  it '#find' do
    session = instance_double(EBSCO::EDS::Session,
      retrieve: instance_double(EBSCO::EDS::Record,
        to_solr: instance_double(SolrDocument)
      )
    )
    expect(EBSCO::EDS::Session).to receive(:new).and_return(session)
    expect(instance.find('123__abc')).to be_truthy
  end

  it '#search'
end
