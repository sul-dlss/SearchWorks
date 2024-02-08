require 'rails_helper'

RSpec.describe 'PURL Embed', :js do
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

    it 'switches iframe src attributes on item selection' do
      expect(find('iframe')['src']).to include('purl.stanford.edu/ct493wg6431')

      # Click the last item
      within('.managed-purl-panel') do
        find('button[data-embed-target="https://purl.stanford.edu/zg338xh5248"]').click
      end
      expect(find('iframe')['src']).to include('purl.stanford.edu/zg338xh5248')

      # Click the first item
      within('.managed-purl-panel') do
        find('button[data-embed-target="https://purl.stanford.edu/ct493wg6431"]').click
      end
      expect(find('iframe')['src']).to include('purl.stanford.edu/ct493wg6431')
    end

    it 'does not include the online panel' do
      expect(page).to have_no_css('.panel-online', visible: true)
    end
  end
end
