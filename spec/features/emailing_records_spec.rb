# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Emailing Records", :js do
  context 'when a user is not logged in' do
    context 'when they are on the record view page' do
      it 'a hidden reCAPTCHA challenge is rendered' do
        visit solr_document_path('14')

        within('.record-toolbar') do
          click_link 'Email'
        end

        expect(page).to have_css 'h2', text: 'Email'

        within('.modal-dialog') do
          expect(page).to have_css('[data-recaptcha-action-value="email"]')
        end
      end
    end
  end

  context 'when a user is logged in' do
    let(:user) { User.new(email: 'example@stanford.edu') }

    before { login_as(user) }

    context 'when on an article page', skip: "Pending searchworks 4 redesign" do
      before { stub_article_service(type: :single, docs: [document]) }

      let(:document) do
        EdsDocument.new(
          id: '123',
          eds_title: 'The title',
          eds_abstract: 'The Abstract',
          eds_subjects_person: '<searchLink fieldCode="SU" term="Person1">Person1</searchLink><br/><searchLink fieldCode="SU" term="Person2">Person2</searchLink>',
          eds_volume: 'The Volumne'
        )
      end

      it 'sends a brief record' do
        visit eds_document_path(document[:id])

        within('.record-toolbar') do
          within('li.dropdown') do
            click_button 'Send to'
            within('.dropdown-menu') do
              click_link 'email'
            end
          end
        end

        expect(URI(find_by_id('email_form')['action']).path).to eq(email_articles_path)

        within('.modal-dialog') do
          fill_in 'to', with: 'email@example.com'
          click_button 'Send'
        end

        expect(page).to have_css '.alert-success', text: 'Email Sent'
      end
    end

    context 'when viewing a catalog record' do
      before do
        visit solr_document_path('14')

        click_link 'Email'
      end

      context 'when "brief record" is selected' do
        it "sends the brief record" do
          expect(page).to have_css 'h2', text: 'Email'

          within('.modal-dialog') do
            fill_in 'to', with: 'email@example.com'
            click_button 'Send'
          end

          expect(page).to have_css '.toast', text: 'Email sent'
        end
      end

      context 'when "Full record" is selected' do
        before do
          within('.modal-dialog') do
            fill_in 'to', with: 'email@example.com'
            choose 'Full record'

            click_button 'Send'
          end
        end

        it 'emails a full record' do
          # triggers capybara to wait until email is sent
          expect(page).to have_css '.toast', text: 'Email sent'

          email = Capybara.string(ActionMailer::Base.deliveries.last.body.to_s)
          expect(email).to have_css('h2', text: /Bibliographic information/)
          expect(email).to have_css('dd', text: /A quartely publication/)
        end
      end
    end

    context 'when on the catalog search page' do
      before do
        stub_article_service(docs: [])

        visit search_catalog_path(q: '14')

        within('#documents article:first-of-type .dropdown') do
          click_button 'More actions'
          click_link 'Email'
        end
      end

      context 'when "brief record" is selected' do
        it "sends the brief record" do
          expect(page).to have_css 'h2', text: 'Email'

          within('.modal-dialog') do
            fill_in 'to', with: 'email@example.com'
            click_button 'Send'
          end

          expect(page).to have_css '.toast', text: 'Email sent'
        end
      end

      context 'when "Full record" is selected' do
        before do
          within('.modal-dialog') do
            fill_in 'To', with: 'email@example.com'
            choose 'Full record'

            click_button 'Send'
          end
        end

        it 'emails a full record' do
          # triggers capybara to wait until email is sent
          expect(page).to have_css '.toast', text: 'Email sent'

          email = Capybara.string(ActionMailer::Base.deliveries.last.body.to_s)
          expect(email).to have_css('h2', text: /Bibliographic information/)
          expect(email).to have_css('dd', text: /A quartely publication/)
        end
      end
    end
  end
end
