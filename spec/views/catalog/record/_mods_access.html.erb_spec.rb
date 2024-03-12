# encoding: UTF-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/record/_mods_access" do
  include ModsFixtures

  describe "Object access" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    before do
      assign(:document, document)
    end

    it "should display access" do
      render
      expect(rendered).to have_css("dt", text: "Use and reproduction")
      expect(rendered).to have_css("dd", text: "Copyright © Stanford University.")
    end
  end
end
