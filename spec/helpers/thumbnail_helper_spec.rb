# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThumbnailHelper do
  describe "#render_cover_image" do
    let(:document) { SolrDocument.new }
    let(:numbers) { { isbn: '', oclc: '', lccn: '' } }
    let(:expected_locals) { { document:, css_class: '' }.merge(numbers) }

    before do
      allow(helper).to receive(:book_ids).and_return(numbers)
    end

    it "renders the appropriate partial for a document's display type" do
      expect(helper).to receive(:render).with({ partial: 'catalog/thumbnails/item_thumbnail', locals: expected_locals })
      helper.render_cover_image(document)
    end
  end
end
