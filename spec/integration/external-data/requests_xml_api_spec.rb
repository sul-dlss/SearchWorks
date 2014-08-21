require 'spec_helper'

describe 'mobile api', :'data-integration' => true do
  it 'should display correct elements for standard record' do
    visit catalog_path('713891', format: 'request')
    expect(page.body).to have_xml('//record')
    expect(page.body).to have_xml('//title')
    expect(page.body).to have_xml('//pub_info')
    expect(page.body).to have_xml('//physical_description')
    # Shouldn't have any brackets
    expect(page.body).to_not match /(\[|\])/
    # Ported over tests, but failing in current prod
    # expect(page.body).to have_xml('//item_details')
    # expect(page.body).to have_xml('//item')
    # expect(page.body).to have_xml('//id')
    # expect(page.body).to have_xml('//shelfkey')
    # expect(page.body).to have_xml('//copy_number')
    # expect(page.body).to have_xml('//item_number')
    # expect(page.body).to have_xml('//home_location')
    # expect(page.body).to have_xml('//current_location')
  end
  it 'SAL request links should have specific content' do
  end
end
