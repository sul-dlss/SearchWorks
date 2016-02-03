require 'spec_helper'

describe DisplayType do
  let(:marc_document) { SolrDocument.new( display_type: ['sirsi']) }
  let(:image_document) { SolrDocument.new( display_type: ['image']) }
  let(:collection_document) { SolrDocument.new( display_type: ['image']) }
  let(:old_file_document) { SolrDocument.new( display_type: ['hydrus_item']) }
  let(:old_image_collection_document) { SolrDocument.new( display_type: ['collection']) }
  let(:old_collection_document) { SolrDocument.new( display_type: ['hydrus_collection']) }
  let(:merged_document) { SolrDocument.new( display_type: ['sirsi', 'file']) }
  let(:merged_collection_document) { SolrDocument.new( display_type: ['sirsi', 'file']) }
  let(:complex_collection_document) { SolrDocument.new( display_type: ['image', 'file']) }
  let(:complex_merged_collection_document) { SolrDocument.new( display_type: ['sirsi', 'image', 'file']) }
  let(:fallback_document) { SolrDocument.new( display_type: ['not-a-real-format']) }
  let(:complex_document) { SolrDocument.new( display_type: ['file', 'image']) }
  let(:non_collection_document) { SolrDocument.new( display_type: ['sirsi']) }
  let(:no_display_type_document) { SolrDocument.new() }
  before do
    allow(collection_document).to receive(:is_a_collection?).and_return(true)
    allow(old_collection_document).to receive(:is_a_collection?).and_return(true)
    allow(old_image_collection_document).to receive(:is_a_collection?).and_return(true)
    allow(merged_collection_document).to receive(:is_a_collection?).and_return(true)
    allow(complex_collection_document).to receive(:is_a_collection?).and_return(true)
    allow(complex_merged_collection_document).to receive(:is_a_collection?).and_return(true)
  end
  describe "single formats" do
    it "should translate sirsi to marc" do
      expect(marc_document.display_type).to eq "marc"
    end
    it "should translate old file item types properly" do
      expect(old_file_document.display_type).to eq "file"
    end
    it "should translate old file collection types properly" do
      expect(old_collection_document.display_type).to eq "file_collection"
    end
    it "should translate old image collection types properly" do
      expect(old_image_collection_document.display_type).to eq "image_collection"
    end
    it "should identify standard types properly" do
      expect(image_document.display_type).to eq "image"
    end
  end
  describe "merged formats" do
    it "should handle merged items correctly" do
      expect(merged_document.display_type).to eq "merged_file"
    end
  end
  describe "collections" do
    describe "single format" do
      it "should append collection to the format" do
        expect(collection_document.display_type).to eq "image_collection"
      end
    end
    it "should be identified when complex" do
      expect(complex_collection_document.display_type).to eq "complex_collection"
    end
    describe "that are merged" do
      it "should be identified" do
        expect(merged_collection_document.display_type).to eq "merged_file_collection"
      end
      it "should be identified when complex" do
        expect(complex_merged_collection_document.display_type).to eq "merged_complex_collection"
      end
    end
    it "should should not be identified when they are non-collection objects" do
      expect(non_collection_document.display_type).to_not include('collection')
    end
  end
  describe "complex formats" do
    it "should be handled appropriately" do
      expect(complex_document.display_type).to eq "complex"
    end
  end
  describe "fallback behavior" do
    it "should fallback on file behavior" do
      expect(fallback_document.display_type).to eq "file"
    end
  end
  it "should return nil when there is no display_type field" do
    expect(no_display_type_document.display_type).to be_nil
  end
end