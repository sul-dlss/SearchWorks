require 'spec_helper'

feature 'Article Record Display' do
  before { stub_article_service(type: :single, docs: [document]) }

  describe 'Subjects' do
    let(:document) do
      SolrDocument.new(id: '123', eds_subjects_person: %w[Person1 Person2])
    end

    it 'are linked' do
      visit article_path(document[:id])

      within 'dd.blacklight-eds_subjects_person' do
        expect(page).to have_link 'Person1'
        expect(page).to have_link 'Person2'
      end
    end
  end

  describe 'Fulltext' do
    let(:document) do
      SolrDocument.new(id: '123', eds_html_fulltext: '<anid>09dfa;</anid><p>This Journal</p>, 10(1)')
    end

    it 'renders HTML' do
      visit article_path(document[:id])
      expect(page).to have_css('.blacklight-eds_html_fulltext')
      expect(page).not_to have_content('<anid>')
    end
  end

  describe 'sidenav mini-map' do
    let(:document) do
      SolrDocument.new(
        id: '123',
        eds_abstract: 'The Abstract',
        eds_subjects_person: %w[A Subject],
        eds_volume: 'The Volumne'
      )
    end

    it 'is present for each section on the page (+ top/bottom)' do
      visit article_path(document[:id])

      within '.side-nav-minimap' do
        expect(page).to have_button('Top')
        expect(page).to have_button('Abstract')
        expect(page).to have_button('Subjects')
        expect(page).to have_button('Details')
        expect(page).to have_button('Bottom')
      end
    end
  end
end
