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
      visit article_path(document[:id])

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

      it 'toggled via panel heading' do
        visit article_path(document[:id])
        expect(page).to have_css('.fulltext-toggle-bar', text: 'Show full text')
        expect(page).to have_no_css('div.blacklight-eds_html_fulltext', visible: true)
        expect(page).to have_no_content('This Journal')

        find_by_id('fulltextToggleBar').click

        expect(page).to have_css('.fulltext-toggle-bar', text: 'Hide full text')
        expect(page).to have_css('div.blacklight-eds_html_fulltext', visible: true)
        expect(page).to have_content('This Journal')
      end

      it 'renders HTML' do
        visit article_path(document[:id])

        find_by_id('fulltextToggleBar').click
        expect(page).to have_css('div.blacklight-eds_html_fulltext', visible: true)
        within('div.blacklight-eds_html_fulltext') do
          expect(page).to have_no_content('<anid>')
        end
      end
    end

    context 'when a user does not have access' do
      it 'renders a login link instead' do
        visit article_path(document[:id])

        expect(page).to have_css('a h2', text: 'Log in to show fulltext')
        expect(page).to have_no_css('button#fulltextToggleBar')
      end
    end
  end

  describe 'Embedded SFX Menu', :js do
    let(:document) do
      EdsDocument.new({
                        'id' => 'abc123',
                        'eds_title' => 'TITLE',
                        'FullText' => {
                          'CustomLinks' => [{
                            'Text' => 'Check SFX for full text',
                            'Url' => 'http://example.com?param=abc&sid=xyz'
                          }]
                        }
                      })
    end
    let(:sfx_xml) { Nokogiri::XML.parse('') }

    before do
      expect_any_instance_of(SfxData).to receive(:sfx_xml).at_least(:once).and_return(sfx_xml)
    end

    context 'when the SFX data is not loaded successfully' do
      it 'returns an error message in the panel' do
        visit article_path(document[:id])

        expect(page).to have_css('turbo-frame#sfx-data')

        expect(page).to have_content 'Content missing'
      end
    end

    context 'when the SFX data is loaded successfully' do
      let(:sfx_xml) do
        Nokogiri::XML.parse(
          <<-XML
            <root>
              <target>
                <service_type>getFullTxt</service_type>
                <target_public_name>TargetName</target_public_name>
                <target_url>http://example.com</target_url>
                <is_related>no</is_related>
                <coverage>
                  <coverage_statement>Statement 1</coverage_statement>
                  <coverage_statement>Statement 2</coverage_statement>
                </coverage>
              </target>
            </root>
          XML
        )
      end

      it 'is loaded asyc on the page' do
        visit article_path(document[:id])

        within('turbo-frame#sfx-data') do
          expect(page).to have_css('ul li a', text: 'TargetName')
          expect(page).to have_css('li ul li', text: 'Statement 1')
        end
      end
    end
  end
end
