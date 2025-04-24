# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Emailing Records", :js do
  context 'when a user is not logged in' do
    it 'the are provided a reCAPTCHA challenge' do
      visit solr_document_path('14')

      within('.record-toolbar') do
        within('li.dropdown') do
          click_button 'Send to'
          within('.dropdown-menu') do
            click_link 'email'
          end
        end
      end

      expect(page).to have_css('h1', text: 'Email This', visible: true)

      within('.modal-dialog') do
        expect(page).to have_css('p', text: 'Stanford affiliates: Log in to skip Captcha.')
      end
    end
  end

  context 'when a user is logged in' do
    let(:user) { User.new(email: 'example@stanford.edu') }

    before { login_as(user) }

    context 'when on an article page' do
      before { stub_article_service(type: :single, docs: [document]) }

      let(:document) do
        SolrDocument.new(
          id: '123',
          eds_title: 'The title',
          eds_abstract: 'The Abstract',
          eds_subjects_person: '<searchLink fieldCode="SU" term="Person1">Person1</searchLink><br/><searchLink fieldCode="SU" term="Person2">Person2</searchLink>',
          eds_volume: 'The Volumne'
        )
      end

      it 'sends a brief record' do
        visit article_path(document[:id])

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

        expect(page).to have_css('.alert-success', text: 'Email Sent', visible: true)
      end
    end

    context 'when viewing a catalog record' do
      before do
        visit solr_document_path('14')

        within('.record-toolbar') do
          within('li.dropdown') do
            click_button 'Send to'
            within('.dropdown-menu') do
              click_link 'email'
            end
          end
        end
      end

      context 'when "brief record" is selected' do
        it "sends the brief record" do
          expect(page).to have_css('h1', text: 'Email This', visible: true)

          within('.modal-dialog') do
            fill_in 'to', with: 'email@example.com'
            click_button 'Send'
          end

          expect(page).to have_css('.alert-success', text: 'Email Sent', visible: true)
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
          expect(page).to have_css('.alert-success', text: 'Email Sent', visible: true)
          # hides the side-nav-minimap
          expect(page).to have_css('.side-nav-minimap', visible: false)

          email = Capybara.string(ActionMailer::Base.deliveries.last.body.to_s)
          expect(email).to have_css('h3', text: /Bibliographic information/)
          expect(email).to have_css('dd', text: /A quartely publication/)
        end
      end
    end
  end
end
