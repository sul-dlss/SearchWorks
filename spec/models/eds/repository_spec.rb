require 'spec_helper'

RSpec.describe Eds::Repository do
  let(:blacklight_config) {
    instance_double(Blacklight::Configuration,
      response_model: Blacklight::Solr::Response,
      document_model: SolrDocument,
      default_per_page: 10
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
    expect(EBSCO::EDS::Session).to receive(:new).twice.and_return(session)
    expect(instance.find('123__abc')).to be_truthy
    expect(instance.find('123__abc__def')).to be_truthy
  end

  describe '#search' do
    context '(normal)' do
      let(:search_builder) do
        instance_double(ArticleSearchBuilder, rows: 10, to_hash: { q: 'my query', rows: 10 })
      end
      it 'uses a session to execute a search' do
        session = instance_double(
          EBSCO::EDS::Session,
          search: instance_double(EBSCO::EDS::Results, to_solr: {})
        )
        expect(EBSCO::EDS::Session).to receive(:new).and_return(session)
        expect(instance.search(search_builder)).to be_truthy
      end
    end

    context '(peek query for prev/next)' do
      let(:search_builder) do
        instance_double(ArticleSearchBuilder, rows: 3, to_hash: { q: 'my query', start: 11, rows: 3 })
      end
      it 'uses a session to run the previous-next search' do
        session = instance_double(
          EBSCO::EDS::Session,
          search: instance_double(EBSCO::EDS::Results, to_solr: double)
        )
        expect(EBSCO::EDS::Session).to receive(:new).and_return(session)
        expect(instance.search(search_builder)).to be_truthy
      end
    end

    context '(id fetch)' do
      let(:search_builder) do
        instance_double(
          ArticleSearchBuilder,
          rows: 10,
          to_hash: { 'q' => { 'id' => 'abc' }, rows: 10 }
        )
      end
      it 'uses a session to run solr_retrieve_list' do
        session = instance_double(
          Eds::Session
        )
        expect(Eds::Session).to receive(:new).and_return(session)
        expect(session).to receive(:solr_retrieve_list)
        instance.search(search_builder)
      end
    end
  end
end
