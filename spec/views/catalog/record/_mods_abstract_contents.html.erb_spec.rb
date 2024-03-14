# encoding: UTF-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/record/_mods_abstract_contents" do
  include ModsFixtures

  describe "Object abstract/contents" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    before do
      assign(:document, document)
    end

    it "should display abstract" do
      render
      expect(rendered).to have_css("dd", text: "Topographical and street map of the")
      expect(rendered).to have_css("dd", text: "This is an amazing table of contents!")
    end
  end
end
