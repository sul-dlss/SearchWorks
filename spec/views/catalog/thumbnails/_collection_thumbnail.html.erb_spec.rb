require 'rails_helper'

RSpec.describe 'catalog/thumbnails/_collection_thumbnail' do
  let(:document) { SolrDocument.new(id: '123') }

  subject { Capybara.string(rendered.to_s) }

  before do
    allow(view).to receive_messages(document:, blacklight_config: CatalogController.blacklight_config)
  end


  context 'gallery view' do
    before { allow(view).to receive(:document_index_view_type).and_return(:gallery) }

    context 'when the first child has a thumbnail' do
      let(:collection_member) { SolrDocument.new(file_id: ['abc123.jp2']) }

      before do
        allow(document).to receive_messages(collection_members: [collection_member])
      end

      it 'is used as collection thumbnail' do
        render
        expect(subject).to have_css('img.stacks-image')
        expect(subject.all('img.stacks-image').first['src']).to eq collection_member.image_urls(:large).first
      end
    end

    context 'when the first child does not have a thumbnail' do
      it 'renders a fake cover' do
        render
        expect(subject).to have_css('span.fake-cover')
      end
    end
  end

  context 'non-gallery view' do
    before { allow(view).to receive(:document_index_view_type).and_return(:list) }

    it 'is not rendered' do
      render
      expect(subject.text).to be_blank
    end
  end
end
