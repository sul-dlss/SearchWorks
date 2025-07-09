# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::ModsAuthorsComponent, type: :component do
  include ModsFixtures

  let(:component) { described_class.new(document:) }
  let(:document) { SolrDocument.new(modsxml: mods_everything, author_struct: author_struct) }

  before do
    render_inline(component)
  end

  context 'when author struct has data' do
    let(:author_struct) { [{ link: 'Dodaro, Gene L.', search: 'Dodaro, Gene L.', post_text: '(Author)' }] }

    it 'displays the link and role from the author struct' do
      expect(page).to have_link('Dodaro, Gene L.', href: "/catalog?q=#{CGI.escape('"Dodaro, Gene L."')}&search_field=search_author")
      expect(page).to have_content(', author')
    end
  end

  context 'when author struct does not have data' do
    let(:author_struct) { [] }

    it 'displays the link and role of the first author from the MODS XML' do
      expect(page).to have_link('J. Smith', href: "/catalog?q=#{CGI.escape('"J. Smith"')}&search_field=search_author")
      expect(page).to have_content(', author')
    end
  end
end
