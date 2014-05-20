require "spec_helper"

describe FeedbackFormHelper do
  describe "show_feedback_form?" do
    it "should return true" do
      expect(helper.show_feedback_form?).to be_true
    end
  end
end
