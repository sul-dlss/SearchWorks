# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sending record emails' do
  context 'when the user is not logged in and the recaptcha fails' do
    before do
      allow_any_instance_of(CatalogController).to receive(:verify_recaptcha).and_return(false) # rubocop:disable RSpec/AnyInstance
    end

    it 'does not allow emails to be submitted' do
      expect do
        post '/view/1/email', params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief' }
      end.not_to(change { ActionMailer::Base.deliveries.count })
    end
  end

  context 'when the user is logged in' do
    before do
      sign_in User.new(email: 'user@stanford.edu')
    end

    it 'sets the provided subject' do
      expect { post '/view/1/email', params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief' } }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq 'Email Subject'
    end

    context 'when brief email is requested' do
      let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

      before do
        allow(SearchWorksRecordMailer).to receive(:email_record).and_return(delivery)
      end

      it 'sends a brief email' do
        post '/view/1/email', params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief' }
        expect(delivery).to have_received(:deliver_now)
      end
    end

    context 'when full email is requested' do
      before do
        allow(SearchWorksRecordMailer).to receive(:full_email_record).and_return(delivery)
      end

      let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

      it 'sends a full email' do
        post '/view/1/email', params: { to: 'email@example.com', subject: 'Email Subject', type: 'full' }
        expect(delivery).to have_received(:deliver_now)
      end
    end

    it 'is able to send emails to multiple addresses' do
      expect do
        post '/view/1/email', params: { to: 'e1@example.com, e2@example.com, e3@example.com', subject: 'Subject', type: 'full' }
      end.to change { ActionMailer::Base.deliveries.count }.by(3)
    end

    describe 'validations' do
      it 'prevents incorrect email types from being sent' do
        expect do
          post '/view/1/email', params: { to: 'email@example.com', type: 'not-a-type' }
        end.not_to(change { ActionMailer::Base.deliveries.count })
        expect(flash[:error]).to eq 'Invalid email type provided'
      end

      it 'validates multiple emails correctly' do
        expect do
          post(
            '/view/1/email',
            params: {
              to: 'email1@example.com, example.com',
              type: 'full',
              id: '1'
            }
          )
        end.not_to(change { ActionMailer::Base.deliveries.count })

        expect(flash[:error]).to eq 'You must enter only valid email addresses.'
      end

      it 'prevents emails with too many addresses from being sent' do
        expect do
          post(
            '/view/1/email',
            params: {
              to: 'email1@example.com,
                   email2@example.com,
                   email3@example.com,
                   email4@example.com,
                   email5@example.com,
                   email6@example.com',
              type: 'full',
              id: '1'
            }
          )
        end.not_to(change { ActionMailer::Base.deliveries.count })

        expect(flash[:error]).to eq 'You have entered more than the maximum (5) email addresses allowed.'
      end
    end
  end
end
