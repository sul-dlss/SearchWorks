require 'spec_helper'

describe 'catalog/access_panels/_appears_in' do
  subject { Capybara.string(rendered) }

  let(:set_documents) { [] }

  before do
    allow(document).to receive_messages(set_document_list: set_documents)
    allow(view).to receive(:link_to_document).with(any_args).and_return('The Set Object')
    allow(view).to receive_messages(current_search_session: {}, search_session: {}, blacklight_config: CatalogController.blacklight_config)
    assign(:document, document)
    render
  end

  context 'when the document is a set member and has a parent set' do
    let(:document) { SolrDocument.new(id: 'abc123', set: ['set1']) }
    let(:set_documents) do
      [{ id: 'abc123', format_main_ssim: 'Map', title_display: 'The Set Object' }]
    end

    it 'renders a panel heading' do
      expect(subject).to have_css('.panel-heading h3', text: 'Item is included in another record')
    end

    describe 'panel body' do
      it 'renders the resource icon in the h4' do
        expect(subject).to have_css('.panel-body h4 span.sul-icon')
      end

      it 'renders the result of #link_to_document in the h4' do
        expect(subject).to have_css('.panel-body h4', text: 'The Set Object')
      end
    end
  end

  context 'when the document is a set member but has no parent set' do
    let(:document) { SolrDocument.new(id: 'abc123', set: ['set1']) }

    it 'renders nothing' do
      expect(rendered).to be_blank
    end
  end

  context 'when the document is not a set member' do
    let(:document) { SolrDocument.new(id: 'abc123') }

    it 'renders nothing' do
      expect(rendered).to be_blank
    end
  end
end
