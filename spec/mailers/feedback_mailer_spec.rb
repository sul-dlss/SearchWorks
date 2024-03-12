# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailer do
  describe "submit_feedback" do
    describe "with all fields" do
      let(:ip) { "123.43.54.123" }
      let(:params) do
        {
          name: 'Mildred Turner',
          to: 'test@test.com',
          user_agent: 'agent #1',
          viewport: 'width:100 height:50',
          last_search: '/?q=kittenz'
        }
      end
      let(:mail) { FeedbackMailer.submit_feedback(params, ip) }

      it "has the correct to field" do
        expect(mail.to).to eq ["fake-email@kittenz.com"]
      end

      it "has the correct subject" do
        expect(mail.subject).to eq "Feedback from SearchWorks"
      end

      it "has the correct from field" do
        expect(mail.from).to eq ["feedback@searchworks.stanford.edu"]
      end

      it "has the correct reply to field" do
        expect(mail.reply_to).to eq ["fake-email@kittenz.com"]
      end

      it "has the right email" do
        expect(mail.body).to have_content "Name: Mildred Turner"
      end

      it "has the right name" do
        expect(mail.body).to have_content "Email: test@test.com"
      end

      it "has the right host" do
        expect(mail.body).to have_content "Host: TEST-HOST"
      end

      it "has the right IP" do
        expect(mail.body).to have_content "123.43.54.123"
      end

      it 'has the user_agent' do
        expect(mail.body).to have_content 'agent #1'
      end

      it 'has the viewport' do
        expect(mail.body).to have_content 'width:100 height:50'
      end

      it 'has the last search' do
        expect(mail.body).to have_content '/?q=kittenz'
      end

      describe 'time' do
        it 'has the current time' do
          expect(Time.zone).to receive(:now).at_least(:once).and_return('NOW!')
          expect(mail.body).to have_content 'Time sent: NOW!'
        end
      end
    end

    describe "without name and email" do
      let(:ip) { "123.43.54.123" }
      let(:params) { {} }
      let(:mail) { FeedbackMailer.submit_feedback(params, ip) }

      it "has the right email" do
        expect(mail.body).to have_content "Name: No name given"
      end

      it "has the right name" do
        expect(mail.body).to have_content "Email: No email given"
      end
    end
  end

  describe 'submit_connection' do
    describe 'with all fields' do
      let(:ip) { '123.43.54.123' }
      let(:params) do
        {
          name: 'Mildred Turner ',
          to: 'test@test.com',
          user_agent: 'agent #1',
          viewport: 'width:100 height:50',
          resource_name: 'Cool database',
          problem_url: 'http://www.example.com/cool',
          message: 'Bad things'
        }
      end
      let(:mail) { FeedbackMailer.submit_connection(params, ip) }

      it 'has the correct to field' do
        expect(mail.to).to eq ['fake-connectionz@kittenz.com']
      end

      it 'has the correct subject' do
        expect(mail.subject).to eq 'Connection problem: Cool database'
      end

      it 'has the correct from field' do
        expect(mail.from).to eq ['test@test.com']
      end

      it 'has the correct reply to field' do
        expect(mail.reply_to).to eq ['fake-connectionz@kittenz.com']
      end

      it 'has the right email' do
        expect(mail.body).to have_content 'Name: Mildred Turner'
      end

      it 'has the right name' do
        expect(mail.body).to have_content 'Email: test@test.com'
      end

      it 'has the right host' do
        expect(mail.body).to have_content 'Host: TEST-HOST'
      end

      it 'has the right IP' do
        expect(mail.body).to have_content '123.43.54.123'
      end

      it 'has the user_agent' do
        expect(mail.body).to have_content 'agent #1'
      end

      it 'has the viewport' do
        expect(mail.body).to have_content 'width:100 height:50'
      end

      it 'has the resource name' do
        expect(mail.body).to have_content 'Cool database'
      end

      it 'has the problem url' do
        expect(mail.body).to have_content 'http://www.example.com/cool'
      end

      it 'has the message' do
        expect(mail.body).to have_content 'Bad things'
      end
    end
  end

  describe 'submit_wrong_book_cover' do
    let(:ip) { '123.45.67.890' }
    let(:params) { { url: 'http://www.example.com/view/1234' } }
    let(:mail) { FeedbackMailer.submit_wrong_book_cover(params, ip) }

    it 'should include the ip address' do
      expect(mail.body).to have_content '123.45.67.890'
    end

    it 'should include the referrer url' do
      expect(mail.body).to have_content 'http://www.example.com/view/1234'
    end
  end
end
