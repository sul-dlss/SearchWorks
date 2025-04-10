# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Eds::Repository do
  let(:blacklight_config) {
    Blacklight::Configuration.new(
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
    before do
      expect(EBSCO::EDS::Session).to receive(:new).and_return(session)
    end

    context 'when doing a search that succeeds' do
      let(:search_builder) do
        instance_double(ArticleSearchBuilder, rows: 10, to_hash: { q: 'my query', rows: 10 })
      end
      let(:session) do
        instance_double(
          EBSCO::EDS::Session,
          search: instance_double(EBSCO::EDS::Results, to_solr: {})
        )
      end

      it 'uses a session to execute a search' do
        expect(instance.search(search_builder)).to be_truthy
      end
    end

    context 'when doing a search that fails with Invalid Content Provider' do
      let(:search_builder) do
        instance_double(ArticleSearchBuilder, rows: 10, to_hash: { q: 'my query', rows: 10 })
      end
      let(:session) do
        instance_double(
          EBSCO::EDS::Session,
          empty_results: { 'SearchResult' => {
            'Data' => { 'Records' => [] },
            'Statistics' => { 'TotalSearchTime' => '5' },
            'AvailableCriteria' => { 'DateRange' => { 'MinDate' => '1501-01', 'MaxDate' => '2018-04' } }
          } },
          config: {}
        )
      end

      before do
        allow(session).to receive(:search).and_raise(EBSCO::EDS::BadRequest.new({ error_body: { 'ErrorDescription' => 'Invalid Content Provider' } }))
      end

      it 'uses a session to execute a search' do
        expect(instance.search(search_builder)).to be_instance_of(Blacklight::Solr::Response)
      end
    end

    context 'when doing a search that fails with any other error' do
      let(:search_builder) do
        instance_double(ArticleSearchBuilder, rows: 10, to_hash: { q: 'my query', rows: 10 })
      end
      let(:session) do
        instance_double(
          EBSCO::EDS::Session,
          empty_results: { 'SearchResult' => {
            'Data' => { 'Records' => [] },
            'Statistics' => { 'TotalSearchTime' => '5' },
            'AvailableCriteria' => { 'DateRange' => { 'MinDate' => '1501-01', 'MaxDate' => '2018-04' } }
          } },
          config: {}
        )
      end

      before do
        allow(session).to receive(:search).and_raise(EBSCO::EDS::BadRequest.new({ error_body: { 'ErrorDescription' => 'broken' } }))
      end

      it 'uses a session to execute a search' do
        expect { instance.search(search_builder) }.to raise_error EBSCO::EDS::BadRequest
      end
    end

    context 'when doing a peek query for prev/next' do
      let(:search_builder) do
        instance_double(ArticleSearchBuilder, rows: 3, to_hash: { q: 'my query', start: 11, rows: 3 })
      end

      let(:session) do
        instance_double(
          EBSCO::EDS::Session,
          search: instance_double(EBSCO::EDS::Results, to_solr: {})
        )
      end

      it 'uses a session to run the previous-next search' do
        expect(instance.search(search_builder)).to be_truthy
      end
    end

    context 'when fetching by id' do
      let(:search_builder) do
        instance_double(
          ArticleSearchBuilder,
          rows: 10,
          to_hash: { 'q' => { 'id' => 'abc' }, rows: 10 }
        )
      end

      let(:session) do
        instance_double(
          Eds::Session,
            solr_retrieve_list: []
        )
      end

      it 'uses a session to run solr_retrieve_list' do
        instance.search(search_builder)
        expect(session).to have_received(:solr_retrieve_list)
      end
    end
  end

  describe '#eds_results_with_date_range' do
    let(:empty_pub_year_response) do
      {
        'date_range' => {
          minyear: '1900',
          maxyear: '1999'
        },
        'facet_counts' => {
          'facet_fields' => {
            'pub_year_tisim' => []
          }
        }
      }
    end

    let(:pupulated_pub_year_response) do
      {
        'facet_counts' => {
          'facet_fields' => {
            'pub_year_tisim' => %w[2010 2012 2014]
          }
        }
      }
    end

    it 'returns the min/max from EDS response date_range in the absence of the pub year field' do
      response = instance.send(:eds_results_with_date_range, empty_pub_year_response)

      expect(response['facet_counts']['facet_fields']['pub_year_tisim']).to eq(%w[1900 1999])
    end

    it 'returns the response unchanged when the pub year field is already populated' do
      response = instance.send(:eds_results_with_date_range, pupulated_pub_year_response)

      expect(response['facet_counts']['facet_fields']['pub_year_tisim']).to eq(%w[2010 2012 2014])
    end
  end
end
