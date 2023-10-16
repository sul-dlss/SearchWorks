require 'rails_helper'

RSpec.describe AllCapsParams do
  let(:controller) { double('CatalogController') }

  before do
    controller.extend(AllCapsParams)
    allow(controller).to receive(:params).and_return(ActiveSupport::HashWithIndifferentAccess.new(params))
  end

  describe "parameters with all capitals" do
    let(:params) { { q: "ALL CAPS", clause: { '1': { query: "TITLE CAPS" } } } }

    it "should downcase the parameter if it is all caps" do
      expect(controller.params[:q]).to eq "ALL CAPS"
      expect(controller.params.dig(:clause, '1', :query)).to eq "TITLE CAPS"
      controller.send(:downcase_all_caps_params)
      expect(controller.params[:q]).to eq "all caps"
      expect(controller.params.dig(:clause, '1', :query)).to eq "title caps"
    end
  end

  describe "parameters w/o all capitals" do
    let(:params) { { q: "all CAPS", clause: { '1': { query: "title CAPS" } } } }

    it "should not downcase the parameter if it not is all caps" do
      expect(controller.params[:q]).to eq "all CAPS"
      expect(controller.params.dig(:clause, '1', :query)).to eq "title CAPS"
      controller.send(:downcase_all_caps_params)
      expect(controller.params[:q]).to eq "all CAPS"
      expect(controller.params.dig(:clause, '1', :query)).to eq "title CAPS"
    end
  end
end
