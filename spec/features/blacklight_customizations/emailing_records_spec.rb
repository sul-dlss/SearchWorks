require "spec_helper"

describe "Emailing Records", type: :feature, js: true do
  it "should be successful" do
    visit catalog_path('14')

    within('.record-toolbar') do
      within('li.dropdown') do
        click_button 'Send to'
        within('.dropdown-menu') do
          click_link 'email'
        end
      end
    end

    within('.modal-dialog') do
      fill_in 'to', with: 'email@example.com'
      click_button 'Send'
    end

    expect(page).to have_css('.alert-success', text: 'Email Sent', visible: true)
  end
end
