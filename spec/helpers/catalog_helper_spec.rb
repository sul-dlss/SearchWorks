# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogHelper do
  include ModsFixtures
  include MarcMetadataFixtures

  describe 'current_view' do
    before do
      allow(helper).to receive_messages(blacklight_config: CatalogController.blacklight_config, blacklight_configuration_context: Blacklight::Configuration::Context.new(helper))
    end

    it 'if params[:view] present, should return it' do
      params = { view: 'gallery' }
      allow(helper).to receive(:params).and_return(params)
      expect(helper.current_view).to eq 'gallery'
    end
    it 'if params is not present, return list' do
      expect(helper.current_view).to eq 'list'
    end
  end

  describe 'new_documents_feed_path' do
    before do
      allow(helper).to receive(:search_state).and_return(Blacklight::SearchState.new({}, CatalogController.blacklight_config))
    end

    it 'returns the search url to an atom feed' do
      expect(helper.new_documents_feed_path).to match %r{^/catalog.atom\?}
    end

    it 'includes the new-to-libs sort key' do
      expect(helper.new_documents_feed_path).to match(/sort=new-to-libs/)
    end

    it 'removes the page parameter' do
      allow(helper).to receive(:search_state).and_return(Blacklight::SearchState.new({ page: 5}, CatalogController.blacklight_config))
      expect(helper.new_documents_feed_path).not_to match(/page=/)
    end
  end

  describe 'link_to_bookplate_search' do
    let(:bookplate) { Bookplate.new('FUND-CODE -|- druid-abc -|- fild-id-123 -|- Bookplate Text') }

    it 'links to the bookplate' do
      expect(link_to_bookplate_search(bookplate)).to include 'f%5Bfund_facet%5D%5B%5D=druid-abc'
    end

    it 'includes the gallery view parameter' do
      expect(link_to_bookplate_search(bookplate)).to include 'view=gallery'
    end

    it 'includes the new to the libraries sort parameter' do
      expect(link_to_bookplate_search(bookplate)).to include 'sort=new-to-libs'
    end

    it 'includes any link options passed in' do
      expect(link_to_bookplate_search(bookplate, class: 'some-class')).to include 'class="some-class"'
    end
  end

  describe '#tech_details' do
    context 'marc document' do
      let(:document) { SolrDocument.new(id: '12345', marc_json_struct: metadata1) }

      it 'adds correct tech details' do
        expect(tech_details(document)).to have_content('Catkey: 12345')
        expect(tech_details(document)).to have_css('a', text: 'Librarian view')
      end
    end

    context 'mods document' do
      let(:document) { SolrDocument.new(id: '12345', modsxml: mods_everything) }

      it 'adds correct tech details' do
        expect(tech_details(document)).to have_content('DRUID: 12345')
        expect(tech_details(document)).to have_css('a', text: 'Librarian view')
      end
    end

    context 'a collection document' do
      let(:document) { SolrDocument.new(id: '12345', modsxml: mods_everything) }

      it 'adds correct tech details' do
        expect(document).to receive(:is_a_collection?).at_least(:once).and_return(true)
        expect(tech_details(document)).to have_content('DRUID: 12345')
        expect(tech_details(document)).to have_css('a', text: 'Librarian view')
        expect(tech_details(document)).to have_css('a', text: 'Collection PURL')
      end
    end
  end

  describe '#iiif_drag_n_drop' do
    it 'creates a IIIF drag n drop link' do
      dnd_link = iiif_drag_n_drop('http://example.io/kittenz/iiif/manifest')
      expect(dnd_link).to match(/data-turbo="false" data-bs-toggle="tooltip" data-bs-placement="left"/)
      expect(dnd_link).to match(/title="Drag icon to any IIIF viewer. — Click icon to learn more."/)
      expect(dnd_link).to match(%r{<img width="40" alt="IIIF Drag-n-drop" src="/images/iiif-drag-n-drop.svg" />})
    end
  end

  describe '#html_present?' do
    it 'returns false for blank values' do
      expect(helper.html_present?(nil)).to be false
      expect(helper.html_present?('')).to be false
    end

    it 'returns false for values with only HTML comments' do
      expect(helper.html_present?('<!-- comment -->')).to be false
    end

    it 'returns true for values with content' do
      expect(helper.html_present?('some content')).to be true
      expect(helper.html_present?('<p>some content</p>')).to be true
      expect(helper.html_present?('<div><!-- comment --></div><p>some content</p>')).to be true
    end
  end
end
