require "spec_helper"

describe 'Customized Layout' do
  before do
    visit root_path
  end
  it 'should include a base64 encoded string in a meta tag' do
    expect(page).to have_css('meta[name="application-name"][value="U2VhcmNoV29ya3M="]', visible: false)
  end
  it 'should include the google-site-verification code' do
    expect(page).to have_css("meta[name='google-site-verification'][content='#{Settings.GOOGLE_SITE_VERIFICATION}']", visible: false)
  end
end
