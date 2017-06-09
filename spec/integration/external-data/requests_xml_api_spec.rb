require 'spec_helper'

describe 'mobile api', :'data-integration' => true do
  it 'should display correct elements for standard record' do
    visit solr_document_path('713891', format: 'request', lib: 'SAL3')
    expect(page.body).to have_xml('//record')
    expect(page.body).to have_xml('//title')
    expect(page.body).to have_xml('//pub_info')
    expect(page.body).to have_xml('//physical_description')
    # Shouldn't have any brackets
    expect(page.body).to_not match /(\[|\])/
    expect(page.body).to have_xml('//item_details')
    expect(page.body).to have_xml('//item')
    expect(page.body).to have_xml('//id')
    expect(page.body).to have_xml('//shelfkey')
    expect(page.body).to have_xml('//copy_number')
    expect(page.body).to have_xml('//item_number')
    expect(page.body).to have_xml('//home_location')
    expect(page.body).to have_xml('//current_location')
  end
  it 'should include a proper shelfkey' do
    visit solr_document_path('351080', format: 'request', lib: "SAL3")
    expect(page.body).to have_xml('//shelfkey')
    expect(page.body).to match(/<shelfkey>lc bf  0001\.000000 a0.500000.*~~~~~~<\/shelfkey>/)
  end
  it 'SAL request links should have specific content' do
  end
end
