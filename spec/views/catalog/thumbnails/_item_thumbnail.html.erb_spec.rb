# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/thumbnails/_item_thumbnail" do
  before do
    allow(view).to receive_messages(css_class: '', oclc: '', isbn: '', lccn: '', document:, blacklight_config: CatalogController.blacklight_config)
  end

  context 'non SDR object' do
    let(:document) { SolrDocument.new(id: '1234', title_display: 'Title') }

    describe "fake covers" do
      it "is included on the gallery view" do
        allow(view).to receive(:document_index_view_type).and_return(:gallery)
        render
        expect(rendered).to have_css('.fake-cover', text: "Title")
      end

      it "is not included on other views" do
        allow(view).to receive(:document_index_view_type).and_return(:list)
        render
        expect(rendered).to have_css('img.cover-image', visible: false)
        expect(rendered).to have_no_css('.fake-cover')
      end
    end
  end

  context 'SDR object' do
    let(:document) { SolrDocument.new(id: '1234', file_id: ['abc123.jp2']) }

    describe 'thumbnail image' do
      it 'is present from stacks' do
        allow(view).to receive(:document_index_view_type).and_return(:gallery)
        render
        html = Capybara.string(rendered.to_s)
        expect(html).to have_css('img.stacks-image')
        expect(html.all('img.stacks-image').first['src']).to match(%r{iiif/abc123/full})
      end

      it 'includes the thumbnail image element if there is a known stacks image' do
        render
        html = Capybara.string(rendered.to_s)
        expect(html).to have_no_css('img.cover-image')
      end
    end
  end
end
