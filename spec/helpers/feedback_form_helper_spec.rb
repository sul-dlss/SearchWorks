require "spec_helper"

describe FeedbackFormHelper do
  describe "show_feedback_form?" do
    let(:form_controller) { FeedbackFormsController.new }
    before do
      form_controller.extend(FeedbackFormHelper)
      form_controller.stub(:controller).and_return(form_controller)
    end
    it "should return false when being viewed under the FeedbackFormsController" do
      expect(form_controller.show_feedback_form?).to be_false
    end
    it "should return true when not under the FeedbackFormsController" do
      expect(helper.show_feedback_form?).to be_true
    end
  end
  describe 'show_quick_report?' do
    it 'should be false unless it meets certain criteria' do
      expect(helper.show_quick_report?).to be_false
    end
    it 'should return true when coming from a show page' do
      params = { controller: 'catalog', action: 'show' }
      helper.stub(:params).and_return(params)
      expect(helper.show_quick_report?).to be_true
    end
    it 'should return true when the referrer is a show page and current controller is feedback' do
      params = { controller: 'feedback_forms', action: 'new' }
      controller.request.should_receive(:referer).and_return('http://127.0.0.1:3000/view/12')
      helper.stub(:params).and_return(params)
      expect(helper.show_quick_report?).to be_true
    end
  end
end
