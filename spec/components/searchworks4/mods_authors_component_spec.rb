# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::ModsAuthorsComponent, type: :component do
  include ModsFixtures

  let(:component) { described_class.new(document:) }
  let(:document) { SolrDocument.new(modsxml: mods_everything, author_struct: author_struct) }

  before do
    render_inline(component)
  end

  context 'when the mods Solr record also has an author struct field' do
    let(:author_struct) { [{ link: 'Dodaro, Gene L.', search: 'Dodaro, Gene L.', post_text: '(Author)' }] }

    it 'displays display name author with link and role' do
      expect(page).to have_link('Dodaro, Gene L.', href: "/catalog?q=#{CGI.escape('"Dodaro, Gene L."')}&search_field=search_author")
      expect(page).to have_content(', author')
    end
  end

  context 'when the mods Solr record has no author_struct field' do
    let(:author_struct) { [] }

    it 'displays first author with link and role' do
      expect(page).to have_link('J. Smith', href: "/catalog?q=#{CGI.escape('"J. Smith"')}&search_field=search_author")
      expect(page).to have_content(', author')
    end
  end
end
