require 'rails_helper'

RSpec.feature 'Article Record Display' do
  before { stub_article_service(type: :single, docs: [document]) }

  describe 'Subjects' do
    let(:document) do
      SolrDocument.new(id: '123', eds_title: 'TITLE', eds_subjects_person: '<searchLink fieldCode="SU" term="Person1">Person1</searchLink><br/><searchLink fieldCode="SU" term="Person2">Person2</searchLink>')
    end

    it 'are linked' do
      visit article_path(document[:id])

      within 'dd.blacklight-eds_subjects_person' do
        expect(page).to have_link 'Person1'
        expect(page).to have_link 'Person2'
      end
    end
  end

  describe 'Fulltext', js: true do
    let(:document) do
      SolrDocument.new(id: '123', eds_title: 'TITLE', eds_html_fulltext_available: true, eds_html_fulltext: '<anid>09dfa;</anid><p>This Journal</p>, 10(1)')
    end

    context 'when a user has access' do
      before do
        login_as(User.new(email: 'example@stanford.edu', affiliations: 'test-stanford:test'))
      end

      it 'toggled via panel heading' do
        visit article_path(document[:id])
        expect(page).to have_css('.fulltext-toggle-bar', text: 'Hide full text')
        expect(page).to have_css('div.blacklight-eds_html_fulltext', visible: true)
        expect(page).to have_content('This Journal')

        find_by_id('fulltextToggleBar').click
        expect(page).to have_css('.fulltext-toggle-bar', text: 'Show full text')
        expect(page).to have_no_css('div.blacklight-eds_html_fulltext', visible: true)
        expect(page).to have_no_content('This Journal')
      end

      it 'renders HTML' do
        visit article_path(document[:id])

        expect(page).to have_css('div.blacklight-eds_html_fulltext', visible: true)
        within('div.blacklight-eds_html_fulltext') do
          expect(page).to have_no_content('<anid>')
        end
      end
    end

    context 'when a user does not have access' do
      it 'renders a login link instead' do
        visit article_path(document[:id])

        expect(page).to have_no_css('button#fulltextToggleBar')

        expect(page).to have_css('a h2', text: 'Log in to show fulltext')
      end
    end
  end

  describe 'sidenav mini-map' do
    let(:document) do
      SolrDocument.new(
        id: '123',
        eds_title: 'The title of the document',
        eds_abstract: 'The Abstract',
        eds_subjects_person: '<searchLink fieldCode="SU" term="Person1">Person1</searchLink><br/><searchLink fieldCode="SU" term="Person2">Person2</searchLink>',
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

  describe 'Embedded SFX Menu', js: true do
    let(:document) do
      SolrDocument.new(
        id: 'abc123',
        eds_title: 'TITLE',
        eds_fulltext_links: [{ 'label' => 'Check SFX for full text', 'url' => 'http://example.com?param=abc&sid=xyz', 'type' => 'customlink-fulltext' }]
      )
    end
    let(:sfx_xml) { Nokogiri::XML.parse('') }

    before do
      expect_any_instance_of(SfxData).to receive(:sfx_xml).at_least(:once).and_return(sfx_xml)
    end

    it 'renders a link to the SFX menu' do
      visit article_path(document[:id])

      within '.article-record-panels .metadata-panels' do
        expect(page).to have_link('See the full find it @ Stanford menu', href: 'http://example.com?param=abc')
      end
    end

    context 'when the SFX data is not loaded successfully' do
      it 'returns an error message in the panel' do
        visit article_path(document[:id])

        within '.article-record-panels .metadata-panels' do
          expect(page).to have_css('[data-behavior="sfx-panel"]', visible: true)

          expect(page).to have_content 'Unable to connect to SFX'
        end
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

        within '.article-record-panels .metadata-panels' do
          expect(page).to have_css('[data-behavior="sfx-panel"]', visible: true)
          within '[data-behavior="sfx-panel"]' do
            expect(page).to have_css('ul li a', text: 'TargetName')
            expect(page).to have_css('li ul li', text: 'Statement 1')
          end
        end
      end
    end
  end

  context 'when a document is restricted' do
    let(:document) do
      SolrDocument.new(
        id: 'abc123',
        'eds_title' => 'This title is unavailable for guests, please login to see more information.',
        'eds_publication_type' => 'Metadata Content'
      )
    end

    it 'does not render metadata' do
      visit article_path(document[:id])

      expect(page).to have_css(
        'h1',
        text: 'This title is not available for guests. Log in to see the title and access the article.'
      )
      expect(page).to have_no_css('.article-record-metadata')
      expect(page).to have_no_content('Metadata Content')
    end
  end
end
