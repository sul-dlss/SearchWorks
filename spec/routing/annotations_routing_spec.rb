require "spec_helper"

describe AnnotationsController, annos: true do
  describe "routing" do

    it "routes to #show" do
      expect(:get => "/annotations/1").to route_to("annotations#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/annotations").to route_to("annotations#create")
    end

    it "routes to #new" do
      expect(:get => "/annotations/new").to route_to("annotations#new")
    end

    it "does NOT route to #index" do
      #expect(:get => "/annotations").to route_to("annotations#index")
      expect(:get => "/annotations").not_to be_routable
    end

    it "does NOT route to #edit" do
      expect(:get => "/annotations/1/edit").not_to route_to("annotations#edit", :id => "1")
      expect(:get => "/annotations/1/edit").not_to be_routable
    end

    it "does NOT route to #update" do
      expect(:put => "/annotations/1").not_to route_to("annotations#update", :id => "1")
      expect(:put => "/annotations/1").not_to be_routable
    end

    it "does NOT route to #destroy" do
      expect(:delete => "/annotations/1").not_to route_to("annotations#destroy", :id => "1")
      expect(:delete => "/annotations/1").not_to be_routable
    end

  end
end
