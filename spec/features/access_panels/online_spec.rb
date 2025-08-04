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
end
