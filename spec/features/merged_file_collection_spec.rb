# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Merged File Collections", :js do
  before do
    stub_article_service(docs: [])
  end

  context "when on the record view" do
    it "displays metadata and file list" do
      visit solr_document_path('38')

      expect(page).to have_css('h1', text: 'Merged File Collection1')

      within('.file-collection-members') do
        expect(page).to have_css("a", text: /File Item/, count: 4)
      end

      expect(page).to have_css('h2', text: 'Contents/Summary')
      expect(page).to have_css('h2', text: 'Subjects')
      expect(page).to have_css('h2', text: 'Bibliographic information')
    end
  end
end
