require 'rails_helper'

RSpec.describe 'Request Links' do
  describe 'Hoover links' do
    context 'in search results' do
      it 'renders a link to the detail/record view instead of holdings' do
        visit search_catalog_path(q: '56')

        within 'table.availability' do
          expect(page).to have_no_content 'ABC 123'

          expect(page).to have_link 'See full record for details'
        end
      end
    end

    context 'on the record view' do
      it 'renders a request button at the location level' do
        visit solr_document_path '56'

        expect(page).to have_css('.request-button', text: 'Request via Aeon')
      end
    end
  end
end
