# frozen_string_literal: true

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

    it "should block potential spam with a href in the message" do
      post :create, params: { message: "I like to spam by sending you a <a href='http://www.somespam.com'>Link</a>.  lolzzzz", url: "http://test.host/", email_address: "" }
      expect(flash[:error]).to eq "Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments."
    end
    it "should block potential spam with a url= in the message" do
      post :create, params: { message: "I like to spam by sending you a <a url='http://www.somespam.com'>Link</a>.  lolzzzz", url: "http://test.host/", email_address: "" }
      expect(flash[:error]).to eq "Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments."
    end
    it "should block potential spam with a http:// in the message" do
      post :create, params: { message: "I like to spam by sending you a http://www.somespam.com.  lolzzzz", url: "http://test.host/", email_address: "" }
      expect(flash[:error]).to eq "Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments."
    end
    it 'should block potential spam with a http:// in the user_agent field' do
      post :create, params: { user_agent: "http://www.google.com", message: "Legit message", url: "http://test.host" }
      expect(flash[:error]).to eq "Your message appears to be spam, and has not been sent."
    end
    it 'should block potential spam with a http:// in the viewport field' do
      post :create, params: { viewport: "http://www.google.com", message: "Legit message", url: "http://test.host" }
      expect(flash[:error]).to eq "Your message appears to be spam, and has not been sent."
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

      it 'allows URLs to be sent through the message' do
        post :create, params: { message: 'This is totally not spam because you know me https://spam.com', url: "http://test.host/", email_address: "" }
        expect(flash[:error]).to be_nil
      end
    end
  end
end
