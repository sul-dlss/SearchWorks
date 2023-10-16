# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Connection form (js)', js: true do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit articles_path
  end

  scenario 'connection form should be shown filled out and submitted' do
    skip('Passes locally, not on Travis.') if ENV['CI']
    find('.connection-problem').click
    expect(page).to have_css('#connection-form', visible: true)
    expect(page).to have_css('button', text: 'Cancel')
    within 'form.feedback-form' do
      fill_in('resource_name', with: 'Resource name')
      fill_in('problem_url', with: 'http://www.example.com/yolo')
      fill_in('message', with: 'This is only a test')
      fill_in('name', with: 'Ronald McDonald')
      fill_in('to', with: 'test@kittenz.eu')
      click_button 'Send'
    end
    wait_for_ajax

    expect(page).to have_css(
      'div.alert-success',
      text: 'Thank you! Your connection problem report has been sent.',
      visible: true
    )
  end
end

RSpec.feature 'Connection form (no js)' do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit articles_path
  end

  scenario 'connection form should be shown filled out and submitted' do
    find('.connection-problem').click
    expect(page).to have_css('#connection-form', visible: true)
    expect(page).to have_css('a', text: 'Cancel')
    within 'form.feedback-form' do
      fill_in('resource_name', with: 'Resource name')
      fill_in('problem_url', with: 'http://www.example.com/yolo')
      fill_in('message', with: 'This is only a test')
      fill_in('name', with: 'Ronald McDonald')
      fill_in('to', with: 'test@kittenz.eu')
      click_button 'Send'
    end
    expect(page).to have_css(
      'div.alert-success',
      text: 'Thank you! Your connection problem report has been sent.'
    )
  end
end
