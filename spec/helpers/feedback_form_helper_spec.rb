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
end
