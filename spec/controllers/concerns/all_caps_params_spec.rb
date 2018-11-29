require "spec_helper"

describe AllCapsParams do
  let(:controller) { double('CatalogContrller') }

  before do
    controller.extend(AllCapsParams)
    allow(controller).to receive(:modifiable_params_keys).and_return(['q', 'search_title'])
    allow(controller).to receive(:params).and_return(HashWithIndifferentAccess.new(params))
  end

  describe "parameters with all capitals" do
    let(:params) { { q: "ALL CAPS", search_title: "TITLE CAPS" } }

    it "should downcase the parameter if it is all caps" do
      expect(controller.params[:q]).to eq "ALL CAPS"
      expect(controller.params[:search_title]).to eq "TITLE CAPS"
      controller.send(:downcase_all_caps_params)
      expect(controller.params[:q]).to eq "all caps"
      expect(controller.params[:search_title]).to eq "title caps"
    end
  end

  describe "parameters w/o all capitals" do
    let(:params) { { q: "all CAPS", search_title: "title CAPS" } }

    it "should not downcase the parameter if it not is all caps" do
      expect(controller.params[:q]).to eq "all CAPS"
      expect(controller.params[:search_title]).to eq "title CAPS"
      controller.send(:downcase_all_caps_params)
      expect(controller.params[:q]).to eq "all CAPS"
      expect(controller.params[:search_title]).to eq "title CAPS"
    end
  end
end
