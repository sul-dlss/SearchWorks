# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::PreferredCitationComponent, type: :component do
  subject(:page) { render_inline(component) }

  let(:document) { SolrDocument.new }
  let(:component) { described_class.new(document:) }

  context 'when the document is not citable' do
    it 'does not render the component' do
      expect(component).not_to be_render
    end
  end

  context 'when the document is citable but has no preferred citation' do
    before do
      allow(document).to receive_messages(citations: {}, citable?: true)
    end

    it 'does not render the component' do
      expect(component).not_to be_render
    end
  end

  context 'when the document is citable and has a preferred citation' do
    let(:preferred_citation) { 'This is the preferred citation.' }

    before do
      allow(document).to receive_messages(citations: { 'preferred' => preferred_citation }, citable?: true)
    end

    it 'renders the component' do
      expect(component).to be_render
    end

    it 'displays the preferred citation' do
      expect(page).to have_text(preferred_citation)
    end
  end

  context 'with a link in the preferred citation' do
    let(:preferred_citation) { 'This is the preferred citation with a link to http://example.com.' }

    before do
      allow(document).to receive_messages(citations: { 'preferred' => preferred_citation }, citable?: true)
    end

    it 'auto-links URLs in the preferred citation' do
      expect(page).to have_link('http://example.com', href: 'http://example.com')
    end
  end
end
