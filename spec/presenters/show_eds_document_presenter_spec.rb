# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShowEdsDocumentPresenter do
  let(:document) { EdsDocument.new }
  let(:view_context) { double('ViewContext', action_name: 'show', blacklight_config: ArticlesController.blacklight_config) }

  subject(:presenter) { described_class.new(document, view_context) }

  describe '#heading' do
    context 'when the document is restricted' do
      let(:document) do
        EdsDocument.new(eds_title: 'This title is unavailable for guests, please login to see more information.')
      end

      it 'renders a custom title' do
        expect(presenter.heading).to eq 'This title is unavailable for guests, please login to see more information.'
      end
    end

    context 'when the document is not restricted' do
      let(:document) do
        EdsDocument.new(eds_title: 'The title of the document')
      end

      it 'renders the document\'s title' do
        expect(presenter.heading).to eq 'The title of the document'
      end
    end
  end
end
