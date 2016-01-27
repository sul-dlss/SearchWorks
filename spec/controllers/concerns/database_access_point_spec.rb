require 'spec_helper'

describe DatabaseAccessPoint do
  let(:controller) { double('CatalogController') }
  let(:page_location) { SearchWorks::PageLocation.new }
  let(:params) { {controller: 'catalog'} }
  let(:blacklight_config) { OpenStruct.new }
  before do
    controller.extend(DatabaseAccessPoint)
    allow(controller).to receive(:page_location).and_return(page_location)
    allow(controller).to receive(:params).and_return(params)
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
  end

  describe "#default_database_sort" do
    before do
      allow(blacklight_config).to receive(:sort_fields).and_return(
        "other sort values" => OpenStruct.new(label: "sort-key"),
        "title sort values"   => OpenStruct.new(label: "title")
      )
      allow(page_location).to receive(:access_point).and_return(OpenStruct.new(:"databases?" => true))
    end
    it "should set the default sort to title when there is no sort param" do
      expect(params[:sort]).to be_blank
      controller.send(:default_databases_sort)
      expect(params[:sort]).to eq "title sort values"
    end
    it "should not set a sort param if one is explicitly set" do
      params[:sort] = "some-sort-param"
      controller.send(:default_databases_sort)
      expect(params[:sort]).to eq "some-sort-param"
    end
  end
  describe "#add_database_topic_facet" do
    before do
      allow(blacklight_config).to receive(:facet_fields).and_return({
        "db_az_subject" => OpenStruct.new(show: false, if: false)
      })
    end
    it "should set show and if to true when under the databases page location" do
      allow(page_location).to receive(:access_point).and_return(OpenStruct.new(:"databases?" => true))
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_falsey
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_falsey
      expect(controller.send(:add_database_topic_facet))
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_truthy
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_truthy
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
  describe "#database_prefix_search" do
    let(:solr_params) { {} }
    let(:user_params) { {} }
    before do
      allow(page_location).to receive(:access_point).and_return(OpenStruct.new(:"databases?" => true))
      allow(controller).to receive(:solr_params).and_return(solr_params)
      allow(controller).to receive(:user_params).and_return(user_params)
    end
    it "should handle 0-9 filters properly" do
      user_params[:prefix] = "0-9"
      controller.send(:database_prefix_search, solr_params, user_params)
      (0..9).to_a.each do |number|
        expect(solr_params[:q]).to match /title_sort:#{number}\*/
      end
      expect(solr_params[:q]).to match /^title_sort:0\*.*title_sort:9\*$/
    end
    it "should handle alpha filters properly" do
      user_params[:prefix] = "B"
      controller.send(:database_prefix_search, solr_params, user_params)
      expect(solr_params[:q]).to eq "title_sort:B*"
    end
    it "should AND user supplied queries" do
      user_params[:prefix] = "B"
      user_params[:q] = "My Query"
      controller.send(:database_prefix_search, solr_params, user_params)
      expect(solr_params[:q]).to eq "title_sort:B* AND My Query"
    end
  end
end
