# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccessPanels::AccessConditionsComponent, type: :component do
  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document:) }

  context "with a use and reproduction statement" do
    let(:document) { SolrDocument.from_fixture("bc798xr9549.yml") }

    it "displays the use and reproduction statement" do
      expect(page).to have_css("dt", text: "Use and reproduction")
      # rubocop:disable Layout/LineLength
      expect(page).to have_css("dd", text: "Property rights reside with the repository. To obtain permission to publish or reproduce, please contact the East Asia Library at eastasialibrary@stanford.edu.")
      # rubocop:enable Layout/LineLength
    end
  end

  context "with a copyright statement" do
    let(:document) { SolrDocument.from_fixture("bx988zq7071.yml") }

    it "displays the copyright statement" do
      expect(page).to have_css("dt", text: "Copyright")
      expect(page).to have_css("dd", text: "Materials may be subject to copyright.")
    end
  end

  context "with a license statement" do
    let(:document) { SolrDocument.from_fixture("bb060nk0241.yml") }

    it "displays the license statement" do
      expect(page).to have_css("dt", text: "License")
      expect(page).to have_css("dd", text: "This work is licensed under an Open Data Commons Attribution License v1.0.")
    end
  end
end
