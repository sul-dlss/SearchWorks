# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::MultipleCitationsComponent, type: :component do
  let(:component) { described_class.new(documents:) }

  before do
    with_request_url request_url do
      with_controller_class BookmarksController do
        allow(vc_test_controller).to receive_messages(current_user: User.new, encrypt_user_id: 123)
        render_inline(component)
      end
    end
  end

  context 'when all items have citations' do
    let(:documents) { [SolrDocument.find('in00000053236'), SolrDocument.find('14434124')] }
    let(:request_url) { "/view/citation?id%5B%5D=in00000053236&id%5B%5D=14434124" }

    it 'renders the citations to the page' do
      expect(page).to have_css 'h3', text: 'Copy citations'

      expect(page).to have_css 'h4', text: 'APA'
      expect(page).to have_button 'Copy'
      expect(page).to have_content '100 years of radio in South Africa'
      expect(page).to have_content 'Between parents'

      expect(page).to have_css 'h4', text: 'MLA', visible: :hidden

      expect(page).to have_link 'In RIS format (Zotero)'
      expect(page).to have_link 'To RefWorks'
      expect(page).to have_link 'To EndNote'
      expect(page).to have_no_css '.alert'
    end
  end

  context 'when some items have only preferred citations (mods)' do
    let(:documents) { [SolrDocument.find('in00000053236'), SolrDocument.find('nj140cs3237')] }
    let(:request_url) { "/view/citation?id%5B%5D=in00000053236&id%5B%5D=nj140cs3237" }

    it 'renders a note about preferred citations' do
      expect(page).to have_text '(Preferred citation / APA unavailable)'
      expect(page).to have_no_css '.alert'
    end
  end

  context 'when some items have unavailable citations' do
    let(:documents) { [SolrDocument.find('1'), SolrDocument.find('nj140cs3237')] }
    let(:request_url) { "/view/citation?id%5B%5D=1&id%5B%5D=nj140cs3237" }

    it 'shows an alert' do
      expect(page).to have_css '.alert', text: 'Citations are unavailable for 1 of the 2 saved records.'
    end
  end

  context 'when all items have only preferred citations (mods)' do
    let(:documents) { [SolrDocument.find('nj140cs3237')] }
    let(:request_url) { "/view/citation?id%5B%5D=nj140cs3237" }

    it 'renders a preferred citation heading and does not show the preferred citation note' do
      expect(page).to have_css 'h4', text: 'Preferred citations'
      expect(page).to have_no_text '(Preferred citation / APA unavailable)'
      expect(page).to have_no_css '.alert'
    end
  end
end
