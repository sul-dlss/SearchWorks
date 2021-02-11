require 'spec_helper'

describe AccessPanelHelper do
  let(:library) { Holdings::Library.new("GREEN") }

  describe "link_to_library_header" do
    it "should return a header with a link to library about page" do
      expect(helper.link_to_library_header(library)).to include "<h3 class=\"\">Green Library</h3>"
    end
  end

  describe "thumb_for_library" do
    it "should return the image tag for the thumbnail for the specified library" do
      img = helper.thumb_for_library(library)
      expect(img).to have_css('img[src^="/assets/GREEN"][data-hidpi-src^="/assets/GREEN@2x"]')
    end
    it "should return the image tag (w/ png extension) for the ZOMBIE library" do
      library = Holdings::Library.new("ZOMBIE")
      img = helper.thumb_for_library(library)
      expect(img).to have_css('img[src^="/assets/ZOMBIE"][data-hidpi-src^="/assets/ZOMBIE@2x"]')
    end
  end

  describe '#display_connection_problem_links?' do
    let(:solr_document_data) { {} }
    let(:document) { SolrDocument.new(solr_document_data) }

    context 'when a public (non-Stanford only) fulltext resource' do
      let(:solr_document_data) do
        { marc_links_struct: [{ fulltext: 'true' }] }
      end

      it { expect(helper.display_connection_problem_links?(document)).to be false }
    end

    context 'when given an sfx document' do
      let(:solr_document_data) { { url_sfx: ['https://example.com/sfx'] } }

      it { expect(helper.display_connection_problem_links?(document)).to be true }
    end

    context 'when given a database' do
      let(:solr_document_data) do
        { marc_links_struct: [{ fulltext: 'true' }], format_main_ssim: ['Database'] }
      end

      it { expect(helper.display_connection_problem_links?(document)).to be true }
    end

    context 'when given a stanford only document' do
      let(:solr_document_data) do
        { marc_links_struct: [{ fulltext: 'true', stanford_only: true }] }
      end

      it { expect(helper.display_connection_problem_links?(document)).to be true }
    end
  end
end
