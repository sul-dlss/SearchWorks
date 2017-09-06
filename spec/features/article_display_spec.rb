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

  describe 'Fulltext', js: true do
    let(:document) do
      SolrDocument.new(id: '123', eds_html_fulltext_available: true, eds_html_fulltext: '<anid>09dfa;</anid><p>This Journal</p>, 10(1)')
    end

    it 'toggled via panel heading' do
      visit article_path(document[:id])
      expect(page).to have_css('.fulltext-toggle-bar', text: 'Hide full text')
      expect(page).to have_css('div.blacklight-eds_html_fulltext', visible: true)
      expect(page).to have_content('This Journal')

      find('#fulltextToggleBar').click
      expect(page).to have_css('.fulltext-toggle-bar', text: 'Show full text')
      expect(page).not_to have_css('div.blacklight-eds_html_fulltext', visible: true)
      expect(page).not_to have_content('This Journal')
    end

    it 'renders HTML' do
      visit article_path(document[:id])
      find('#fulltextToggleBar').click
      expect(page).to have_css('.blacklight-eds_html_fulltext')
      within('div.blacklight-eds_html_fulltext') do
        expect(page).not_to have_content('<anid>')
      end
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

  describe 'Embedded SFX Menu', js: true do
    let(:document) do
      SolrDocument.new(
        id: 'abc123',
        eds_fulltext_links: [{ 'label' => 'Check SFX for full text', 'url' => 'http://example.com?param=abc&sid=xyz' }]
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
end
