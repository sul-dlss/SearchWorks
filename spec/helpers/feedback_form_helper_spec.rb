# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackFormHelper do
  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  let(:user) { User.new(email: 'example@stanford.edu') }

  describe '#render_feedback_form' do
    context 'connection type' do
      it { expect(helper.render_feedback_form('connection')).to include 'Name of resource' }
    end

    context 'anything else' do
      before do
        allow(helper).to receive(:on_campus_or_su_affiliated_user?).and_return false
      end

      it { expect(helper.render_feedback_form('other')).not_to include 'Name of resource' }
    end
  end

  describe "show_feedback_form?" do
    let(:form_controller) { FeedbackFormsController.new }

    before do
      form_controller.extend(FeedbackFormHelper)
      allow(form_controller).to receive(:controller).and_return(form_controller)
    end

    it "should return false when being viewed under the FeedbackFormsController" do
      expect(form_controller.show_feedback_form?).to be_falsey
    end
    it "should return true when not under the FeedbackFormsController" do
      expect(helper.show_feedback_form?).to be_truthy
    end
  end

  describe 'show_quick_report?' do
    it 'should be false unless it meets certain criteria' do
      expect(helper.show_quick_report?).to be_falsey
    end
    it 'should return true when coming from a show page' do
      params = { controller: 'catalog', action: 'show' }
      allow(helper).to receive(:params).and_return(params)
      expect(helper.show_quick_report?).to be_truthy
    end
    it 'should return true when the referrer is a show page and current controller is feedback' do
      params = { controller: 'feedback_forms', action: 'new' }
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/view/12')
      allow(helper).to receive(:params).and_return(params)
      expect(helper.show_quick_report?).to be_truthy
    end
  end

  describe 'refered_from_catalog_show?' do
    it 'should be true if referer is from view show' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/view/12')
      expect(helper.refered_from_catalog_show?).to be_truthy
    end
    it 'should be true if referer is from catalog show' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/catalog/12')
      expect(helper.refered_from_catalog_show?).to be_truthy
    end
    it 'should be false if not a show page' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return('http://127.0.0.1:3000/catalog?f%5Baccess_facet%5D%5B%5D=At+the+Library&f%5Baccess_facet%5D%5B%5D=Online')
      expect(helper.refered_from_catalog_show?).to be_falsey
    end
    it 'should be false if referer is nil' do
      expect(controller.request).to receive(:referer).at_least(:once).and_return(nil)
      expect(helper.refered_from_catalog_show?).to be_falsey
    end
  end
end
