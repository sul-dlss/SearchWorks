# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Online Access Panel" do
  scenario "for databases" do
    visit solr_document_path('24')

    within(".panel-online") do
      expect(page).to have_css('h2', text: 'Search this database')
      expect(page).to have_css('a', text: 'Report a connection problem')
    end
  end

  context 'when a record with an SFX link' do
    before do
      expect_any_instance_of(SfxData).to receive(:sfx_xml).at_least(:once).and_return(sfx_xml)
    end

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

    it 'renders the panel', :js do
      visit solr_document_path('57')

      within('.panel-online') do
        expect(page).to have_css('h2', text: 'Online')

        within('turbo-frame#sfx-data') do
          expect(page).to have_css('ul li a', text: 'TargetName')
          expect(page).to have_css('li ul li', text: 'Statement 1')
          expect(page).to have_css('li ul li', text: 'Statement 2')
        end
      end
    end
  end
end
