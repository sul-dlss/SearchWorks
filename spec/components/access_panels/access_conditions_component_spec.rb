# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccessPanels::AccessConditionsComponent, type: :component do
  include ModsFixtures

  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document:) }
  let(:document) { SolrDocument.new(modsxml:) }

  context "when access conditions are on the record" do
    let(:modsxml) { mods_001 }

    it "displays access" do
      expect(page).to have_css('h2', text: "Access conditions")

      expect(page).to have_css("dt", text: "Use and reproduction")
      expect(page).to have_css("dd", text: "Copyright © Stanford University.")
    end
  end

  context "when access conditions are not provided" do
    let(:modsxml) { mods_only_title }

    it "displays correct sections" do
      expect(page).to have_no_css('h2', text: "Access conditions")
    end
  end
end
