require "spec_helper"

describe "Record view pagination", js: true do
  before do
    visit root_path
  end

  it "should pass the appropriate counter" do
    fill_in 'q', with: ''
    click_button 'search'

    within('.page_links') do
      click_link 'Next'
    end

    document_title = all('.index_title a').first.try(:text)

    expect(document_title).to be_present

    within(first('.document')) do
      expect(page).to have_css('.document-counter', text: '21')
      click_link document_title
    end

    within('.record-toolbar') do
      expect(page).to have_content('21 of')
      click_link 'Back to results'
    end

    within(first('.document')) do
      expect(page).to have_css('.document-counter', text: '21')
      expect(page).to have_css('.index_title a', text: document_title)
    end
  end
end
