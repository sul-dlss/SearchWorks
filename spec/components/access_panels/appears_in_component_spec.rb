require 'rails_helper'

RSpec.describe AccessPanels::AppearsInComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:set_documents) { [] }

  before do
    allow(document).to receive_messages(set_document_list: set_documents)

    with_controller_class(CatalogController) do
      render_inline(component)
    end
  end

  context 'when the document is a set member and has a parent set' do
    let(:document) { SolrDocument.new(id: 'abc123', set: ['set1']) }
    let(:set_documents) do
      [{ id: 'abc123', format_main_ssim: 'Map', title_display: 'The Set Object' }]
    end

    it 'renders a panel heading' do
      expect(page).to have_css('.card-header h3', text: 'Item is included in another record')
    end

    describe 'panel body' do
      it 'renders the resource icon in the h4' do
        expect(page).to have_css('.card-body h4 span.sul-icon')
      end

      it 'renders the result of #link_to_document in the h4' do
        expect(page).to have_css('.card-body h4', text: 'The Set Object')
      end
    end
  end

  context 'when the document is a set member but has no parent set' do
    let(:document) { SolrDocument.new(id: 'abc123', set: ['set1']) }

    it 'renders nothing' do
      expect(page).not_to have_selector '.panel'
    end
  end

  context 'when the document is not a set member' do
    let(:document) { SolrDocument.new(id: 'abc123') }

    it 'renders nothing' do
      expect(page).not_to have_selector '.panel'
    end
  end
end
