require 'spec_helper'

class EdsPagingTestClass
  include EdsPaging
end

RSpec.describe EdsPaging do
  subject(:controller) { EdsPagingTestClass.new }

  context '#PagingWindow and #previous_and_next_document_params' do
    let(:hit) { 0 } # index is 0-based
    let(:max) { 999_999_999 }
    let(:window) { EdsPagingTestClass::PagingWindow.new(hit, max) }

    context 'first hit' do
      it 'first page without a previous hit' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1 # start_page is 1-based
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to be_nil
        expect(window.next_hit).to eq 1
      end
    end

    context 'second hit' do
      let(:hit) { 1 }
      let(:previous_and_next_document_params) { @eds_params, @prev_hit, @next_hit = controller.previous_and_next_document_params(hit) }

      it 'first page with both prev/next hits' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 0
        expect(window.next_hit).to eq 2
      end

      it 'registers correct EDS parameters' do
        expect(previous_and_next_document_params).to be_truthy
        expect(@eds_params).to include(page_number: 1, results_per_page: 10)
        expect(@prev_hit).to eq 0
        expect(@next_hit).to eq 2
      end
    end

    context 'tenth hit (boundary condition)' do
      let(:hit) { 9 }

      it 'first page with both prev/next hits' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 11
        expect(window.prev_hit).to eq 8
        expect(window.next_hit).to eq 10
      end
    end

    context 'eleventh hit (boundary condition)' do
      let(:hit) { 10 }

      it 'first page with both prev/next hits' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 12
        expect(window.prev_hit).to eq 9
        expect(window.next_hit).to eq 11
      end
    end

    context 'last hit (boundary condition)' do
      let(:hit) { 9 }
      let(:max) { 10 }

      it 'last page without a next hit (preserves per_page size)' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 8
        expect(window.next_hit).to be_nil
      end
    end

    context 'middle of page hit (probed)' do
      let(:hit) { 32 }

      it 'is in middle' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 4
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 1
        expect(window.next_hit).to eq 3
      end
    end

    context 'last hit (probed)' do
      let(:hit) { 39 }
      let(:max) { 40 }

      it 'last page without a next hit' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 4
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 8
        expect(window.next_hit).to be_nil
      end
    end

    context 'only hit' do
      let(:hit) { 0 }
      let(:max) { 1 }

      it 'no prev or next' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to be_nil
        expect(window.next_hit).to be_nil
      end
    end

    context 'last hit on short list' do
      let(:hit) { 1 }
      let(:max) { 2 }

      it 'no next' do
        expect(window).to be_truthy
        expect(window.start_page).to eq 1
        expect(window.per_page).to eq 10
        expect(window.prev_hit).to eq 0
        expect(window.next_hit).to be_nil
      end
    end

    context 'invalid hit' do
      let(:hit) { 999 }
      let(:max) { 40 }

      it 'raises error' do
        expect { window }.to raise_error(ArgumentError)
      end
    end

    context 'negative hit' do
      let(:hit) { -1 }

      it 'raises error' do
        expect { window }.to raise_error(ArgumentError)
      end
      it 'raises error on params' do
        expect { controller.previous_and_next_document_params(hit) }.to raise_error(ArgumentError)
      end
    end
  end

  context '#get_previous_and_next_documents_for_search' do
    let(:hit) { 1 }
    before do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      expect(controller).to receive(:search_builder).and_return(instance_double(Blacklight::SearchBuilder, with: { q: 'my query'}))
      expect(controller).to receive(:repository).and_return(Eds::Repository.new(double))
      _response, @docs = controller.get_previous_and_next_documents_for_search(hit, { q: 'my query' })
    end

    it 'finds the prev/next docs' do
      expect(@docs.first).to be_truthy
      expect(@docs.first['id']).to eq 'abc123'
      expect(@docs.last).to be_truthy
      expect(@docs.last['id']).to eq 'wqoeif'
    end

    context 'last hit' do
      let(:hit) { StubArticleService::SAMPLE_RESULTS.length - 1 }

      it 'grabs the penultimate hit for the previous doc but no next doc' do
        expect(@docs.first).to be_truthy
        expect(@docs.first['id']).to eq '321cba'
        expect(@docs.last).to be_nil
      end
    end
  end
end
