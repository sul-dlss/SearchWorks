require "spec_helper"

describe TagsController do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/tags").to route_to("tags#index")
    end

    it "routes to #new" do
      expect(:get => "/tags/new").to route_to("tags#new")
    end

    it "routes to #show" do
      expect(:get => "/tags/1").to route_to("tags#show", :id => "1")
    end

    it "does NOT route to #edit" do
      expect(:get => "/tags/1/edit").to_not route_to("tags#edit", :id => "1")
      expect(:get => "/tags/1/edit").to_not be_routable
    end

    it "routes to #create" do
      expect(:post => "/tags").to route_to("tags#create")
    end

    it "does NOT route to #update" do
      expect(:put => "/tags/1").to_not route_to("tags#update", :id => "1")
      expect(:put => "/tags/1").to_not be_routable
    end

    it "does NOT route to #destroy" do
      expect(:delete => "/tags/1").to_not route_to("tags#destroy", :id => "1")
      expect(:delete => "/tags/1").to_not be_routable
    end

  end
end
