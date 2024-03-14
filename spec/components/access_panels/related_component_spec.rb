# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::RelatedComponent, type: :component do
  it 'should be hidden by default' do
    render_inline(described_class.new(document: SolrDocument.new))
    expect(page).to have_css('div.panel-related', visible: false)
  end

  describe 'WorldCat Link' do
    before do
      render_inline(described_class.new(document: SolrDocument.new(oclc: ['12345'])))
    end

    it 'should render an OCLC link' do
      expect(page).to have_css('div.panel-related', visible: true)
      expect(page).to have_css('li.worldcat a', text: 'Find it at other libraries via WorldCat')
    end
  end
end
