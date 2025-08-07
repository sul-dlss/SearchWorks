# frozen_string_literal: true

require "rails_helper"

RSpec.describe Articles::DocumentListComponent, type: :component do
  let(:component) { described_class.new(document: presenter) }
  let(:view_context) { vc_test_controller.view_context }
  let(:presenter) { IndexEdsDocumentPresenter.new(document, view_context) }
  let(:document) do
    EdsDocument.new(
      id: 'x',
      eds_title:
    )
  end
  let(:current_search_session) { nil }

  before do
    allow(vc_test_controller).to receive_messages(view_context: view_context)
    allow(view_context).to receive_messages(search_session: {}, current_search_session: nil, session_tracking_path: nil, bookmarked?: false)
  end

  context 'when a document is restricted' do
    let(:eds_title) { 'This title is unavailable for guests, please login to see more information.' }

    it 'displays EdsRestrictedComponent' do
      render_inline(component)

      expect(page).to have_content 'This title cannot be displayed for guests.'
      expect(page).to have_css('button', class: 'stanford-only')
    end
  end

  context 'when the document has a date' do
    let(:document) do
      EdsDocument.new(
        id: 'x',
        eds_title: 'Sample Document'
      )
    end

    before do
      allow(document).to receive(:eds_publication_year).and_return('2023')
    end

    it 'formats the date correctly' do
      render_inline(component)

      expect(page).to have_css '.main-title-date', text: '[2023]'
    end
  end
end
