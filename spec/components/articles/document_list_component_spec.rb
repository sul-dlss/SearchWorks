# frozen_string_literal: true

require "rails_helper"

RSpec.describe Articles::DocumentListComponent, type: :component do
  let(:component) { described_class.new(document: presenter) }
  let(:view_context) { vc_test_controller.view_context }
  let(:presenter) { IndexEdsDocumentPresenter.new(document, view_context) }
  let(:document) do
    SolrDocument.new(
      id: 'x',
      eds_title:
    )
  end

  before do
    render_inline(component)
  end

  context 'when a document is restricted' do
    let(:eds_title) { 'This title is unavailable for guests, please login to see more information.' }

    it 'displays EdsRestrictedComponent' do
      expect(page).to have_content 'This title cannot be displayed for guests.'
      expect(page).to have_css('button', class: 'stanford-only')
    end
  end
end
