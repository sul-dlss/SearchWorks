require 'spec_helper'

describe QuickReportsController do
  describe 'format json' do
    it 'should return json success' do
      post :create, url: 'http://www.example.com/view/123', format: 'json'
      flash[:success].should eq '<strong>Thank you!</strong> Your feedback has been sent.'
    end
    it 'should return html success' do
      post :create, url: 'http://www.example.com/view/123'
      flash[:success].should eq '<strong>Thank you!</strong> Your feedback has been sent.'
    end
  end
end
