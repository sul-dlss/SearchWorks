require 'spec_helper'

describe DatabaseAccessPoint do
  let(:controller) { double('CatalogController') }
  let(:page_location) { SearchWorks::PageLocation.new }
  let(:params) { {controller: 'catalog'} }
  let(:blacklight_config) { OpenStruct.new }
  before do
    controller.extend(DatabaseAccessPoint)
    controller.stub(:page_location).and_return(page_location)
    controller.stub(:params).and_return(params)
    controller.stub(:blacklight_config).and_return(blacklight_config)
  end

  describe "#default_database_sort" do
    before do
      blacklight_config.stub(:sort_fields).and_return(
        "other sort values" => OpenStruct.new(label: "sort-key"),
        "title sort values"   => OpenStruct.new(label: "title")
      )
      page_location.stub(:access_point).and_return(OpenStruct.new(:"databases?" => true))
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
      blacklight_config.stub(:facet_fields).and_return({
        "db_az_subject" => OpenStruct.new(show: false, if: false)
      })
    end
    it "should set show and if to true when under the databases page location" do
      page_location.stub(:access_point).and_return(OpenStruct.new(:"databases?" => true))
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_false
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_false
      expect(controller.send(:add_database_topic_facet))
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_true
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_true
    end
    it "should set the show and if to true when under the facet action" do
      params[:action] = "facet"
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_false
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_false
      expect(controller.send(:add_database_topic_facet))
      expect(blacklight_config.facet_fields["db_az_subject"].show).to be_true
      expect(blacklight_config.facet_fields["db_az_subject"].if).to   be_true
    end
  end
  describe "#database_prefix_search" do
    let(:solr_params) { {} }
    let(:user_params) { {} }
    before do
      page_location.stub(:access_point).and_return(OpenStruct.new(:"databases?" => true))
      controller.stub(:solr_params).and_return(solr_params)
      controller.stub(:user_params).and_return(user_params)
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
