require "spec_helper"

describe CollectionHelper do
  describe "#link_to_collection_members" do
    let(:document) { SolrDocument.new(id: '1234') }

    it "should link to the given text" do
      expect(link_to_collection_members("LinkText", document)).to match /<a href.*>LinkText<\/a>/
    end
    it "should link document id" do
      expect(link_to_collection_members("LinkText", document)).to match /<a href=\".*collection.*=1234\".*/
    end
  end

  describe "#collections_search_params" do
    it "should be the collection_type facet value of 'Digital Collection" do
      expect(collections_search_params).to have_key(:f)
      expect(collections_search_params[:f]).to have_key(:collection_type)
      expect(collections_search_params[:f][:collection_type]).to eq ["Digital Collection"]
    end
  end

  describe "#collection_members_path" do
    let(:document) { SolrDocument.new(id: '1234') }

    it "should link document id" do
      expect(collection_members_path(document)).to match /.*collection.*=1234.*/
    end
  end

  describe "#collection_members_enumeration" do
    let(:document) { SolrDocument.new }
    let(:collection_members) { [SolrDocument.new, SolrDocument.new] }
    let(:no_collection_doc) { SolrDocument.new }

    before do
      allow(collection_members).to receive(:total).and_return("5")
      allow(document).to receive(:collection_members).and_return(collection_members)
      allow(no_collection_doc).to receive(:collection_members).and_return([])
    end

    it "should return the correct number of document including the #total" do
      expect(collection_members_enumeration(document)).to eq "5 items online"
    end
    it "should not return anything if an document does not have collection members" do
      expect(collection_members_enumeration(no_collection_doc)).to be_nil
    end
  end

  describe '#text_for_inner_members_link' do
    let(:document) { SolrDocument.new }
    let(:collection_members) { [SolrDocument.new, SolrDocument.new] }

    before do
      expect(collection_members).to receive(:total).at_least(:once).and_return(2)
      expect(document).to receive(:collection_members).at_least(:once).and_return(collection_members)
    end

    it 'pluralizes the collection members total' do
      expect(text_for_inner_members_link(document)).to start_with 'Explore this collection'
    end
  end

  describe "#collection_breadcrumb_value" do
    it "should return the collection name when present in the @document_list" do
      allow(helper).to receive(:document_presenter).and_return(
        OpenStruct.new(heading: 'Title2')
      )
      @document_list = [
        SolrDocument.new(collection: ['12345', '54321'], collection_with_title: ['12345 -|- Title1', '54321 -|- Title2'])
      ]
      expect(helper.send(:collection_breadcrumb_value, '54321')).to eq 'Title2'
    end
    it "should return the ID if there is no @documen_list" do
      expect(helper.send(:collection_breadcrumb_value, '54321')).to eq '54321'
    end
    it "should return the ID if there are no matching collections in the @document_list" do
      @document_list = [
        SolrDocument.new(collection: ['12345', '54321'], collection_with_title: ['12345 -|- Title1', '54321 -|- Title2'])
      ]
      expect(helper.send(:collection_breadcrumb_value, '11111')).to eq '11111'
    end
  end
end
