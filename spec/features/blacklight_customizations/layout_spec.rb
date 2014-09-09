require "spec_helper"

describe 'Customized Layout' do
  it 'should include a base64 encoded string in a meta tag' do
    visit root_path
    expect(page).to have_css('meta[name="application-name"][value="U2VhcmNoV29ya3M="]', visible: false)
  end
end
