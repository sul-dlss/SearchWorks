# frozen_string_literal: true

require 'spec_helper'

describe AlternateCatalogHelper do
  before do
    allow(helper).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    allow(helper).to receive(:blacklight_configuration_context).and_return(Blacklight::Configuration::Context.new(helper))
  end

  describe 'show_alternate_catalog?' do
    context 'with q params and non-gallery view' do
      it do
        controller.params[:q] = 'query'
        expect(helper.show_alternate_catalog?).to eq true
      end
    end

    context 'no q params' do
      it do
        expect(helper.show_alternate_catalog?).to eq false
      end
    end

    context 'gallery view' do
      it do
        controller.params[:view] = 'gallery'
        expect(helper.show_alternate_catalog?).to eq false
      end
    end
  end
end
