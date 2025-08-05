# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Article Record Display' do
  before { stub_article_service(type: :single, docs: [document]) }

  describe 'Subjects' do
    let(:document) do
      EdsDocument.new({
                        id: '123',
                        eds_title: 'The title of the document',
                        "Items" => [
                          {
                            "Name" => "SubjectPerson",
                            "Data" => '<searchLink fieldCode="SU" term="Person1">Person1</searchLink><br/><searchLink fieldCode="SU" term="Person2">Person2</searchLink>'
                          }
                        ]
                      })
    end

    it 'are linked' do
      visit eds_document_path(document[:id])

      expect(page).to have_css('dd.blacklight-eds_subjects_person a', text: 'Person1')
      expect(page).to have_css('dd.blacklight-eds_subjects_person a', text: 'Person2')
    end
  end

  describe 'Fulltext', :js do
    let(:document) do
      EdsDocument.new({
                        'id' => '123',
                        'eds_title' => 'TITLE',
                        'FullText' => {
                          'Text' => {
                            'Value' => '<anid>09dfa;</anid><p>This Journal</p>, 10(1)',
                            'Availability' => '1'
                          }
                        }
                      })
    end

    context 'when a user has access' do
      before do
        login_as(User.new(email: 'example@stanford.edu', affiliations: 'test-stanford:test'))
      end

      it 'renders HTML' do
        visit eds_document_path(document[:id])

        expect(page).to have_link 'Full text'
        click_link 'Full text'

        switch_to_window(windows.last)
        expect(page).to have_content('This Journal')
        expect(page).to have_no_content('<anid>')
      end
    end

    context 'when a user does not have access' do
      it 'renders a login link instead' do
        visit eds_document_path(document[:id])
        expect(page).to have_link 'Full text', href: %r{/sso/login}
      end
    end
  end
end
