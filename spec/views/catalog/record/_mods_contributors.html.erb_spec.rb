# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/record/_mods_contributors" do
  include ModsFixtures

  describe "Contributors section" do
    before do
      assign(:document, SolrDocument.new(modsxml: mods_everything))
      render
    end

    it 'should display primary authors' do
      expect(rendered).to have_css('dt', text: 'Author')
      expect(rendered).to have_css('dd', text: 'J. Smith')
    end

    it "should display secondary authors" do
      expect(rendered).to have_css("dt", text: "Producer")
      expect(rendered).to have_css("dd a", text: "B. Smith")
    end
  end
end
