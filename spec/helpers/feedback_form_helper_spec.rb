# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackFormHelper do
  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  let(:user) { User.new(email: 'example@stanford.edu') }

  describe '#render_connection_form' do
    context 'connection type' do
      it { expect(helper.render_connection_form).to include 'Name of resource' }
    end
  end

  describe "show_connection_form?" do
    let(:form_controller) { FeedbackFormsController.new }

    before do
      form_controller.extend(FeedbackFormHelper)
      allow(form_controller).to receive(:controller).and_return(form_controller)
    end

    it "returns false when being viewed under the FeedbackFormsController" do
      expect(form_controller.show_connection_form?).to be_falsey
    end
    it "returns true when not under the FeedbackFormsController" do
      expect(helper.show_connection_form?).to be_truthy
    end
  end

  describe 'show_quick_report?' do
    it 'is false unless it meets certain criteria' do
      expect(helper.show_quick_report?).to be_falsey
    end
    it 'returns true when coming from a show page' do
      params = { controller: 'catalog', action: 'show' }
      allow(helper).to receive(:params).and_return(params)
      expect(helper.show_quick_report?).to be_truthy
    end
    it 'returns true when the referrer is a show page and current controller is feedback' do
      params = { controller: 'feedback_forms', action: 'new' }
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/view/12')
      allow(helper).to receive(:params).and_return(params)
      expect(helper.show_quick_report?).to be_truthy
    end
  end

  describe 'refered_from_catalog_show?' do
    it 'is true if referer is from view show' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/view/12')
      expect(helper.refered_from_catalog_show?).to be_truthy
    end
    it 'is true if referer is from catalog show' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/catalog/12')
      expect(helper.refered_from_catalog_show?).to be_truthy
    end
    it 'is false if not a show page' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/catalog?f%5Baccess_facet%5D%5B%5D=At+the+Library&f%5Baccess_facet%5D%5B%5D=Online')
      expect(helper.refered_from_catalog_show?).to be_falsey
    end
    it 'is false if referer is nil' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return(nil)
      expect(helper.refered_from_catalog_show?).to be_falsey
    end
  end
end
