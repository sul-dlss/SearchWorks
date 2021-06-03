require 'spec_helper'

describe DatabaseAccessPoint do
  let(:controller) { double('CatalogController') }
  let(:params) { { controller: 'catalog', action: 'index' } }
  let(:blacklight_config) { OpenStruct.new }

  before do
    controller.extend(DatabaseAccessPoint)
    allow(controller).to receive(:params).and_return(params)
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
  end

  describe "#add_database_topic_facet" do
    before do
      allow(blacklight_config).to receive(:facet_fields).and_return({
        "db_az_subject" => OpenStruct.new(show: false, if: false)
      })
    end

    context 'when under the databases page location' do
      before do
        params[:f] = { format_main_ssim: ["Database"] }
      end

      it "should set show and if to true" do
        expect(blacklight_config.facet_fields["db_az_subject"].show).to be_falsey
        expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_falsey
        expect(controller.send(:add_database_topic_facet))
        expect(blacklight_config.facet_fields["db_az_subject"].show).to be_truthy
        expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_truthy
      end
    end

    it "should set the show and if to true when under the facet action" do
      params[:action] = "facet"
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_falsey
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_falsey
      expect(controller.send(:add_database_topic_facet))
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_truthy
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_truthy
    end
  end
end
