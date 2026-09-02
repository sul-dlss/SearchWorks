# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrSet do
  let(:solr_data) { { id: '12345', set: ['set1'], set_with_title: ['set1 -|- SetABC'] } }
  let(:documents) { [SolrDocument.new(id: 'set1', title_display: 'SetABC')] }
  let(:stub_response) { instance_double(Blacklight::Solr::Response, documents:) }

  subject { SolrDocument.new(solr_data) }

  context 'when an item is a member of a set' do
    describe '#set_member?' do
      it 'is true' do
        expect(subject).to be_set_member
      end
    end

    describe '#parent_sets' do
      it 'returns an array of solr documents' do
        allow(Blacklight.default_index).to receive(:search)
          .with(params: { fq: 'id:set1' })
          .and_return(stub_response)

        expect(subject.parent_sets).to be_all do |set|
          set.is_a?(SolrDocument)
        end
        expect(Blacklight.default_index).to have_received(:search).with(params: { fq: 'id:set1' })
      end
    end

    describe '#index_parent_sets' do
      before do
        expect(Blacklight).not_to receive(:solr)
      end

      it 'returns an array of solr documents without hitting solr' do
        expect(subject.index_parent_sets).to be_all do |set|
          set.is_a?(SolrDocument)
        end
      end

      it 'splits the ID and title from the set_with_title field' do
        parent = subject.index_parent_sets.first
        expect(parent[:id]).to eq 'set1'
        expect(parent[:title_display]).to eq 'SetABC'
      end
    end

    describe 'private methods' do
      describe '#set_solr_params' do
        before { subject[:set] << 'set2' }

        it 'returns an fq with the set IDs joined with an "OR"' do
          expect(subject.send(:set_solr_params)[:params]).to eq(fq: 'id:set1 OR id:set2')
        end
      end
    end
  end
end
