# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bookmarking Items' do
  let(:oclc_citation) { instance_double(Citations::OclcCitation) }

  before do
    allow(Citations::OclcCitation).to receive(:new).and_return(oclc_citation)
    allow(oclc_citation).to receive_messages(
      citations_by_oclc_number: { '12345' => { 'mla' => '<p class="citation_style_MLA">MLA Citation</p>' } }
    )
  end

  context 'Citations', :js do
    it 'is viewable grouped by title and citation format' do
      visit root_path
      fill_in :q, with: ''
      click_button 'search'

      within(first('.document')) do
        find('input.toggle-bookmark').click
      end

      wait_for_ajax

      within(all('.document').last) do
        find('input.toggle-bookmark').click
      end

      wait_for_ajax

      visit '/selections'

      expect(page).to have_css('.document', count: 2)

      click_link 'Cite 1 - 2'

      wait_for_ajax

      within('.modal-dialog') do
        expect(page).to have_css('div#all')
        click_button 'By citation format'
        expect(page).to have_css('div#biblio')
      end
    end
  end
end
