# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::ModsDocumentComponent, type: :component do
  include ModsFixtures
  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document: ShowDocumentPresenter.new(document, view_context)) }
  let(:view_context) { ActionController::Base.helpers }

  before do
    allow(view_context).to receive_messages(blacklight_config: CatalogController.blacklight_config, action_name: 'show')
  end

  context 'when a document has a druid' do
    context 'with published content' do
      let(:document) do
        SolrDocument.new(id: 'abc213', druid: 'abc123', dor_resource_count_isi: 1, modsxml: mods_001)
      end

      it 'includes the embed viewer' do
        expect(page).to have_css('div[data-behavior="purl-embed"]')
      end
    end

    context 'without published content' do
      let(:document) do
        SolrDocument.new(id: 'abc213', druid: 'abc123', dor_resource_count_isi: 0, modsxml: mods_001)
      end

      it 'does not include the purl-embed-viewer element' do
        expect(page).to have_no_css('div[data-behavior="purl-embed"]')
      end
    end

    context 'without dor_resource_count_isi' do
      let(:document) { SolrDocument.new(id: 'abc213', druid: 'abc123', modsxml: mods_001) }

      it 'includes the purl-embed-viewer element' do
        expect(page).to have_css('div[data-behavior="purl-embed"]')
      end
    end
  end

  context 'when a document does not have a druid' do
    let(:document) { SolrDocument.new(id: 'abc213', modsxml: mods_001) }

    it 'does not include the purl-embed-viewer element' do
      expect(page).to have_no_css('div[data-behavior="purl-embed"]')
    end
  end
end
