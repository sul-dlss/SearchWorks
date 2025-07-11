# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/stackmap' do
  include MarcMetadataFixtures

  describe 'StackMap view' do
    before do
      allow(view).to receive_messages(blacklight_config: CatalogController.blacklight_config,
                                      blacklight_configuration_context: Blacklight::Configuration::Context.new(controller))
      assign(:document, SolrDocument.new(id: '12345', marc_json_struct: metadata1))
      render
    end

    it 'renders stackmap map template' do
      expect(rendered).to have_css('div.modal-header h2.modal-title')

      expect(rendered).to have_css('div.stackmap .map-template')

      expect(rendered).to have_css('.zoom-controls .zoom-in')
      expect(rendered).to have_css('.zoom-controls .zoom-out')
      expect(rendered).to have_css('.zoom-controls .zoom-fit')
      expect(rendered).to have_css('.nav-item .show-description')

      expect(rendered).to have_css('.map-template .osd')
      expect(rendered).to have_css('.text-directions')
    end
  end
end
