# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::ThumbnailComponent, type: :component do
  subject(:component) { described_class.new presenter: presenter }

  let(:current_search_session) { nil }
  let(:view_context) { vc_test_controller.view_context }
  let(:presenter) { instance_double(Blacklight::DocumentPresenter, document: document) }

  before do
    allow(vc_test_controller).to receive_messages(view_context: view_context)
    allow(view_context).to receive_messages(search_session: {}, current_search_session: nil, session_tracking_path: nil)
  end

  context 'with a MARC record' do
    let(:document) { SolrDocument.new id: '1', isbn_display: ['978-3-16-148410-0'], oclc: ['123456789'], lccn: ['987654321'] }

    it "renders the google books placeholder" do
      render_inline(component)

      expect(page).to have_css('.document-thumbnail .cover-image[data-isbn="ISBN9783161484100"]', visible: :hidden)
      expect(page).to have_no_css('.document-thumbnail .fake-cover')
    end

    context 'when in e.g. gallery view' do
      subject(:component) { described_class.new presenter: presenter, render_placeholder: true }

      it 'also renders the placeholder' do
        render_inline(component)

        expect(page).to have_css('.document-thumbnail .cover-image[data-isbn="ISBN9783161484100"]', visible: :hidden)
        expect(page).to have_css('.document-thumbnail .fake-cover')
      end
    end
  end

  context 'with an SDR object' do
    let(:document) { SolrDocument.new(id: '1234', file_id: ['abc123.jp2']) }

    it 'is present from stacks' do
      render_inline(component)

      expect(page).to have_css('img.stacks-image')
      expect(page.first('img.stacks-image')['src']).to match(%r{iiif/abc123/full})
      expect(page).to have_no_css('.document-thumbnail .fake-cover')
    end

    context 'when in e.g. gallery view' do
      subject(:component) { described_class.new presenter: presenter, render_placeholder: true }

      let(:document) { SolrDocument.new(id: '1234', file_id: []) }

      it 'renders the placeholder' do
        render_inline(component)

        expect(page).to have_css('.document-thumbnail .fake-cover', text: 'Book cover not available')
      end
    end
  end

  context 'with a collection' do
    let(:document) { SolrDocument.new(id: '123', collection_type: ['Digital Collection']) }

    context 'when the first child has a thumbnail' do
      subject(:component) { described_class.new presenter: presenter, render_placeholder: true, render_collection_thumbnail_from_member: true }

      let(:collection_member) { SolrDocument.new(file_id: ['abc123.jp2']) }

      before do
        allow(document).to receive_messages(collection_members: [collection_member])
      end

      it 'is used as collection thumbnail' do
        render_inline(component)

        expect(page).to have_css('img.stacks-image')
        expect(page.first('img.stacks-image')['src']).to eq collection_member.image_urls(:large).first
      end
    end

    context 'when we do not want to look up the collection members' do
      subject(:component) { described_class.new presenter: presenter }

      it 'renders nothing' do
        render_inline(component)

        expect(page).to have_no_css('img').or have_no_css('.fake-cover').or have_no_css('.document-thumbnail')
      end
    end
  end
end
