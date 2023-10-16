# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlternateCatalogHelper do
  before do
    allow(helper).to receive_messages(blacklight_config: CatalogController.blacklight_config, blacklight_configuration_context: Blacklight::Configuration::Context.new(helper))
  end

  describe 'show_alternate_catalog?' do
    context 'with q params and non-gallery view' do
      it do
        controller.params[:q] = 'query'
        expect(helper.show_alternate_catalog?).to be true
      end
    end

    context 'no q params' do
      it do
        expect(helper.show_alternate_catalog?).to be false
      end
    end

    context 'gallery view' do
      it do
        controller.params[:view] = 'gallery'
        expect(helper.show_alternate_catalog?).to be false
      end
    end
  end
end
