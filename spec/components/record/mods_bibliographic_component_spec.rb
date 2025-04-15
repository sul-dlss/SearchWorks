# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Record::ModsBibliographicComponent, type: :component do
  include ModsFixtures

  describe "Object bibliographic" do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }
    let(:component) { described_class.new(document:) }

    before do
      render_inline(component)
    end

    it "displays titles" do
      expect(page).to have_css("dt", text: "Alternative title")
      expect(page).to have_css("dd", text: "A record")
    end
    it "displays audience" do
      expect(page).to have_css("dt", text: "Who?")
      expect(page).to have_css("dd", text: "Cat loverz")
    end
    it "displays notes" do
      expect(page).to have_css("dt", text: "Note")
      expect(page).to have_css("dd", text: "Pick up milk")
      expect(page).to have_css("dt", text: "Notez")
      expect(page).to have_css("dd", text: "Pick up milkz")
    end
    it "displays identifier" do
      expect(page).to have_css("dt", text: "uri")
      expect(page).to have_css("dd", text: "http://www.myspace.com/myband")
    end
    it "displays location" do
      expect(page).to have_css("dt", text: "Secret Location")
      expect(page).to have_css("dd", text: "NorCal")
    end
  end
end
