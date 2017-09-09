require 'spec_helper'

describe IndexDocumentPresenter do
  let(:document) { SolrDocument.new }
  let(:view_context) { double('ViewContext', blacklight_config: Blacklight::Configuration.new) }
  subject(:presenter) { described_class.new(document, view_context) }

  describe '#label' do
    context 'when the document is restricted' do
      let(:document) do
        SolrDocument.new(eds_title: 'This title is unavailable for guests, please login to see more information.')
      end

      it 'renders a custom title' do
        expect(
          presenter.label(:eds_title)
        ).to eq SolrDocument::UPDATED_EDS_RESTRICTED_TITLE
      end
    end

    context 'when the document is not restricted' do
      let(:document) do
        SolrDocument.new(eds_title: 'The title of the document')
      end

      it 'renders the document\'s title' do
        expect(
          presenter.label(:eds_title)
        ).to eq 'The title of the document'
      end
    end
  end
end
