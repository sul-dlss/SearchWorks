# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccessPanels::AccessConditionsComponent, type: :component do
  include ModsFixtures

  subject(:page) { render_inline(component) }

  let(:component) { described_class.new(document:) }

  context "with MODS records" do
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

  context "with Cocina records" do
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
end
