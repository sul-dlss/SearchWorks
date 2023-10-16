require 'rails_helper'

RSpec.describe 'PURL Embed', js: true do
  it 'should be present for images' do
    visit solr_document_path('mf774fs2413')

    within('.purl-embed-viewer') do
      expect(page).to have_css('iframe')
    end
  end

  describe 'many purls for one ckey' do
    before do
      visit solr_document_path('8923346')
    end

    it 'has the managed purl panel with an item for each managed purl' do
      within('.managed-purl-panel') do
        expect(page).to have_css('li[data-embed-target="https://purl.stanford.edu/ct493wg6431"]')
        expect(page).to have_css('li[data-embed-target="https://purl.stanford.edu/zg338xh5248"]')
      end
    end

    it 'switches iframe src attributes on item selection' do
      first_item = all('li[data-embed-target="https://purl.stanford.edu/ct493wg6431"]').first
      last_item = all('li[data-embed-target="https://purl.stanford.edu/zg338xh5248"]').first
      expect(all('iframe').first['src']).to include('purl.stanford.edu/ct493wg6431')

      last_item.click
      expect(all('iframe').first['src']).to include('purl.stanford.edu/zg338xh5248')

      first_item.click
      expect(all('iframe').first['src']).to include('purl.stanford.edu/ct493wg6431')
    end

    it 'should not include the online panel' do
      expect(page).not_to have_css('.panel-online', visible: true)
    end
  end
end
