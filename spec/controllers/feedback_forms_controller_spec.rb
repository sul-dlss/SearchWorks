require 'rails_helper'

RSpec.describe FeedbackFormsController do
  context 'when the current user is anonymous' do
    context 'when they fill in the reCAPTCHA' do
      before do
        expect_any_instance_of(FeedbackFormsController).to receive(:verify_recaptcha).and_return(true)
      end

      it 'send an email' do
        expect do
          post :create, params: { url: 'http://test.host/', message: 'Howdy' }
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

    context 'when they do not fill in the reCAPTCHA' do
      before do
        expect_any_instance_of(FeedbackFormsController).to receive(:verify_recaptcha).and_return(false)
      end

      it 'does not send an email' do
        expect do
          post :create, params: { url: 'http://test.host/', message: 'Howdy' }
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end

  context 'when a current user is present' do
    before { login_as user }

    let(:user) { User.new }

    describe "format json" do
      it "should return json success" do
        post :create, params: { url: "http://test.host/", message: "Hello Kittenz", format: "json" }
        expect(flash[:success]).to eq "<strong>Thank you!</strong> Your feedback has been sent."
      end
      it "should return html success" do
        post :create, params: { url: "http://test.host/", message: "Hello Kittenz" }
        expect(flash[:success]).to eq "<strong>Thank you!</strong> Your feedback has been sent."
      end
    end

    describe "validate" do
      it "should return an error if no message is sent" do
        post :create, params: { url: "http://test.host/", message: "", email_address: "" }
        expect(flash[:error]).to eq "A message is required"
      end
    end
  end
end
