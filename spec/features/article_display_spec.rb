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
end
