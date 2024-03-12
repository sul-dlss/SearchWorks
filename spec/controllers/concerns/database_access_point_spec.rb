# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseAccessPoint do
  let(:blacklight_config) { CatalogController.blacklight_config.deep_dup }
  let(:search_state) { Blacklight::SearchState.new(params, blacklight_config, other_controller) }
  let(:other_controller) { instance_double(CatalogController, controller_name: 'catalog', action_name: 'index') }
  let(:params) { {} }

  before do
    controller.extend(DatabaseAccessPoint)
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
  end

  describe "#add_database_topic_facet" do
    before do
      blacklight_config.facet_fields['db_az_subject'] = OpenStruct.new(show: false, if: false)
    end

    context 'when under the databases page location' do
      let(:controller) { instance_double(CatalogController, search_state:, action_name: 'index') }
      let(:params) { { f: { format_main_ssim: ["Database"] } } }

      it "sets show and if to true" do
        expect(blacklight_config.facet_fields["db_az_subject"].show).to be_falsey
        expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_falsey
        expect(controller.send(:add_database_topic_facet))
        expect(blacklight_config.facet_fields["db_az_subject"].show).to be_truthy
        expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_truthy
      end
    end

    context 'when under the facet action' do
      let(:controller) { instance_double(CatalogController, search_state:, action_name: 'facet') }

      it "sets the show and if to true" do
        expect(blacklight_config.facet_fields["db_az_subject"].show).to be_falsey
        expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_falsey
        expect(controller.send(:add_database_topic_facet))
        expect(blacklight_config.facet_fields["db_az_subject"].show).to be_truthy
        expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_truthy
      end
    end
  end
end
