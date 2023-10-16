require 'rails_helper'

RSpec.describe 'catalog/stackmap' do
  include MarcMetadataFixtures

  describe 'StackMap view' do
    before do
      assign(:document, SolrDocument.new(id: '12345', marc_json_struct: metadata1))
      render
    end

    it 'renders stackmap map template' do
      expect(rendered).to have_css('div.modal-header h3.modal-title')

      expect(rendered).to have_css('div.stackmap .map-template')

      expect(rendered).to have_css('span.library')
      expect(rendered).to have_css('span.floorname')

      expect(rendered).to have_css('.zoom-controls a.zoom-in')
      expect(rendered).to have_css('.zoom-controls a.zoom-out')
      expect(rendered).to have_css('.zoom-controls a.zoom-fit')
      expect(rendered).to have_css('.controls .show-description')

      expect(rendered).to have_css('.map-template .osd')
      expect(rendered).to have_css('.map-template .text-directions')
    end
  end
end
