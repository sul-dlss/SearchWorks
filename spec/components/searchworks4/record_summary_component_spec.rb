# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::RecordSummaryComponent, type: :component do
  before do
    with_controller_class CatalogController do
      presenter = vc_test_controller.helpers.document_presenter(document)
      render_inline(described_class.new(presenter:))
    end
  end

  context 'with no authors' do
    let(:document) { SolrDocument.find('2') }

    it "renders the description" do
      expect(page).to have_content "Another object"
      expect(page).to have_css "ul"
      expect(page).to have_no_content "ul li"
    end
  end
end
