require 'spec_helper'

describe FeedbackFormsController do
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
      post :create, params: { :url => "http://test.host/", :message => "", :email_address => "" }
      expect(flash[:error]).to eq "A message is required"
    end
    it "should block potential spam with a href in the message" do
      post :create, params: { :message => "I like to spam by sending you a <a href='http://www.somespam.com'>Link</a>.  lolzzzz", :url => "http://test.host/", :email_address => "" }
      expect(flash[:error]).to eq "Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments."
    end
    it "should block potential spam with a url= in the message" do
      post :create, params: { :message => "I like to spam by sending you a <a url='http://www.somespam.com'>Link</a>.  lolzzzz", :url => "http://test.host/", :email_address => "" } 
      expect(flash[:error]).to eq "Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments."
    end
    it "should block potential spam with a http:// in the message" do
      post :create, params: { :message => "I like to spam by sending you a http://www.somespam.com.  lolzzzz", :url => "http://test.host/", :email_address => "" }
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
    it "should return an error if a bot fills in the email_addrss field (email is correct field)" do
      post :create, params: { :message => "I am spamming you!", :url => "http://test.host/", :email_address => "spam!" }
      expect(flash[:error]).to eq "You have filled in a field that makes you appear as a spammer.  Please follow the directions for the individual form fields."
    end
  end
end
