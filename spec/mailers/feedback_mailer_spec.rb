require "spec_helper"

describe FeedbackMailer do
  describe "submit_feedback" do
    describe "with all fields" do
      let(:ip) {"123.43.54.123"}
      let(:params) { { name: "Mildred Turner ", to: "test@test.com" } }
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
    end

    describe "without name and email" do
      let(:ip) {"123.43.54.123"}
      let(:params) { {  } }
      let(:mail) { FeedbackMailer.submit_feedback(params, ip) }

      it "has the right email" do
        expect(mail.body).to have_content "Name: No name given"
      end

      it "has the right name" do
        expect(mail.body).to have_content "Email: No email given"
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
