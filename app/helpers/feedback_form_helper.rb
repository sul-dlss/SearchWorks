module FeedbackFormHelper

  def show_feedback_form?
    !controller.instance_of?(FeedbackFormsController)
  end

end
