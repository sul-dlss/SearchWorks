require "spec_helper"

describe CollectionAccessPointHelper do
  describe "#get_collection" do
    describe "when no document is present" do
      it "should return parameter values" do
        params[:f] = {collection: ["29"]}
        response.should_receive(:docs).exactly(1).times.and_return([])
        helper.get_collection
        expect(helper.instance_variable_get("@parent").nil?).to be_true
      end
    end
    describe "when documents are present" do
      it "should return 1st doc parent collection values" do
        params[:f] = {collection: ["29"]}
        response.should_receive(:docs).exactly(2).times.and_return([{collection: ["29"]}])
        helper.get_collection
        expect(helper.instance_variable_get("@parent").nil?).to be_false
        expect(helper.instance_variable_get("@parent")[:title_display]).to eq "Image Collection1"
        expect(helper.instance_variable_get("@parent")[:summary_display]).to eq ["A collection of fixture images from the SearchWorks development index."]
      end
    end
  end
end
