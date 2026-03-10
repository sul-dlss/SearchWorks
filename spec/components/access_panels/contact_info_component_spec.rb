# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccessPanels::ContactInfoComponent, type: :component do
  subject(:page) { render_inline(described_class.new(document:)) }

  context "without a contact email" do
    let(:document) { SolrDocument.from_fixture("bc798xr9549.yml") }

    it "does not render the contact email section" do
      expect(page).to have_no_text("Contact information")
    end
  end

  context "with a contact email" do
    let(:document) { SolrDocument.from_fixture("bb060nk0241.yml") }

    it "renders the contact email as a mailto link" do
      expect(page).to have_css("dd a[href='mailto:htakemur@stanford.edu']", text: "htakemur@stanford.edu")
    end
  end
end
