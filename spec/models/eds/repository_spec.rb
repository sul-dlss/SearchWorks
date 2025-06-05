# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Eds::Repository do
  let(:blacklight_config) {
    Blacklight::Configuration.new(
      response_model: Eds::Response,
      document_model: EdsDocument,
      default_per_page: 10
    )
  }

  subject(:instance) { described_class.new(blacklight_config) }

  it 'has the right methods' do
    expect(instance.respond_to?(:search)).to be_truthy
    expect(instance.respond_to?(:find)).to be_truthy
  end

  it '#find' do
    session = instance_double(Eds::Session,
                              retrieve: instance_double(EdsDocument)
                             )
    expect(Eds::Session).to receive(:new).and_return(session)
    expect(instance.find('123__abc')).to be_truthy
    expect(instance.find('123__abc__def')).to be_truthy
  end

  describe '#search' do
    before do
      expect(Eds::Session).to receive(:new).and_return(session)
    end

    context 'when doing a search that succeeds' do
      let(:search_builder) do
        instance_double(Eds::SearchBuilder, rows: 10, to_hash: { q: 'my query', rows: 10 })
      end
      let(:session) do
        instance_double(
          Eds::Session,
          search: []
        )
      end

      it 'uses a session to execute a search' do
        expect(instance.search(search_builder)).to be_truthy
      end
    end

    context 'when doing a search that fails with any other error' do
      let(:search_builder) do
        instance_double(Eds::SearchBuilder, rows: 10, to_hash: { q: 'my query', rows: 10 })
      end
      let(:session) do
        instance_double(
          Eds::Session
        )
      end

      before do
        allow(session).to receive(:search).and_raise(Faraday::Error)
      end

      it 'uses a session to execute a search' do
        expect { instance.search(search_builder) }.to raise_error Faraday::Error
      end
    end

    context 'when doing a peek query for prev/next' do
      let(:search_builder) do
        instance_double(Eds::SearchBuilder, rows: 3, to_hash: { q: 'my query', start: 11, rows: 3 })
      end

      let(:session) do
        instance_double(
          Eds::Session,
          search: instance_double(Eds::Response)
        )
      end

      it 'uses a session to run the previous-next search' do
        expect(instance.search(search_builder)).to be_truthy
      end
    end
  end
end
