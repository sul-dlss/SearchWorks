# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::RelatedComponent, type: :component do
  it 'is hidden by default' do
    render_inline(described_class.new(document: SolrDocument.new))
    expect(page).to have_css('div.panel-related', visible: false)
  end

  describe 'WorldCat Link' do
    before do
      render_inline(described_class.new(document: SolrDocument.new(oclc: ['12345'])))
    end

    it 'renders an OCLC link' do
      expect(page).to have_css('div.panel-related', visible: true)
      expect(page).to have_css('li.worldcat a', text: 'Find it at other libraries via WorldCat')
    end
  end

  describe 'finding aid links' do
    context 'when there is a WorldCat link' do
      before do
        document = SolrDocument.new(
          oclc: ['12345'],
          marc_links_struct: [{ href: 'http://oac.cdlib.org/findaid/ark:/something-else', note: 'finding aid is here' },
                              { href: 'http://archives.stanford.edu/findaid/ark:/archives-ark-id', note: 'finding aid' }]
        )
        render_inline(described_class.new(document:))
      end

      it 'renders the additional non-preferred (OAC) finding aid with the oac image class' do
        expect(page).to have_css('li.oac a', text: 'Online Archive of California')
        expect(page).to have_link 'Online Archive of California', href: 'http://oac.cdlib.org/findaid/ark:/something-else'
      end
    end

    context 'when there is no WorldCat link' do
      before do
        document = SolrDocument.new(
          marc_links_struct: [{ href: 'http://oac.cdlib.org/findaid/ark:/something-else', note: 'finding aid is here' },
                              { href: 'http://archives.stanford.edu/findaid/ark:/archives-ark-id', note: 'finding aid' }]
        )
        render_inline(described_class.new(document:))
      end

      it 'does not display the additional finding aid' do
        expect(page).to have_css('div.panel-related', visible: false)
        expect(page).to have_no_link 'Online Archive of California', href: 'http://oac.cdlib.org/findaid/ark:/something-else'
      end
    end
  end
end
