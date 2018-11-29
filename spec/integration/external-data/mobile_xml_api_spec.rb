require 'spec_helper'

describe 'mobile api', :'data-integration' => true do
  describe 'show page' do
    it 'shows correct mobile elements' do
      visit solr_document_path('7861312', format: 'mobile')
      expect(page.body).to have_xml('//title')
      expect(page.body).to have_xml('//image_url')
      expect(page.body).to have_xml('//image_url_lg')
      expect(page.body).to have_xml('//formats')
      expect(page.body).to have_xml('//format')
      expect(page.body).to have_xml('//isbns')
      expect(page.body).to have_xml('//isbn')
      expect(page.body).to have_xml('//imprint')
      expect(page.body).to have_xml('//item_id')
      expect(page.body).to have_xml('//urls')
      expect(page.body).to have_xml('//url')
      expect(page.body).to have_xml('//holdings')
      expect(page.body).to have_xml('//library')
      expect(page.body).to have_xml('//location')
      expect(page.body).to have_xml('//callnumber')
    end

    it 'shows correct drupal api elements' do
      visit solr_document_path('2757829', format: 'mobile', drupal_api: true)
      expect(page.body).not_to have_xml('//image_url')
    end

    it 'shows GryphonDor Item elements correctly' do
      visit solr_document_path('wx633yw5780', format: 'mobile')
      expect(page.body).to have_xml('//collection')
      expect(page.body).to have_xml('//id')
    end

    it 'shows mobile image record elements correctly' do
      visit solr_document_path('wt030np1013', format: 'mobile')
      expect(page.body).to have_xml('//response')
      expect(page.body).to have_xml('//LBItem')
      expect(page.body).to have_xml('//title')
      expect(page.body).to have_xml('//format')
      expect(page.body).to have_xml('//record_url')
    end

    it 'shows course reserves api correctly' do
      visit solr_document_path('1711966', format: 'mobile')
      expect(page.body).to have_xml('//response')
      expect(page.body).to include('The horn / Kurt Janetzky and Bernhard Bruchle ; translated from the German by James Chater')
    end
  end

  describe 'result page' do
    it 'shows correct mobile elements' do
      visit search_catalog_path(format: 'mobile', q: 'harry')
      expect(page.body).to have_xml('//response')
      expect(page.body).to have_xml('//LBItem')
      expect(page.body).to have_xml('//title')
      expect(page.body).to have_xml('//mobile_record')
      expect(page.body).to have_xml('//image_url')
      expect(page.body).to have_xml('//image_url_lg')
      expect(page.body).to have_xml('//formats')
      expect(page.body).to have_xml('//format')
      expect(page.body).not_to have_xml('//holding')
    end

    it 'shows correct drupal api elements' do
      visit search_catalog_path(format: 'mobile', drupal_api: true, q: 'harry potter')
      expect(page.body).not_to have_xml('//image_url')
      expect(page.body).not_to have_xml('//availability')
      expect(page.body).not_to have_xml('//holding')
      visit search_catalog_path(format: 'mobile', q: '7155816')
      expect(page.body).to have_xml('//database_url')
    end

    it 'shows correct image search elements' do
      visit search_catalog_path(format: 'mobile', q: 'Birds Eye VIew of San Francisco')
      expect(page.body).to have_xml('//response')
      expect(page.body).to have_xml('//LBItem')
      expect(page.body).to have_xml('//title')
      visit search_catalog_path(format: 'mobile', q: 'Jacobus Houbraken')
      expect(page.body).to have_xml('//response')
      expect(page.body).to have_xml('//LBItem')
    end
  end
end
