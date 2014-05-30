require "spec_helper"

describe SolrDocument do
  describe "MarcLinks" do
    it "should include marc links" do
      expect(subject).to be_kind_of MarcLinks
    end
  end
  describe "DatabaseDocument" do
    it "should include database document" do
      expect(subject).to be_kind_of DatabaseDocument
    end
  end
  describe "DisplayType" do
    it "should include display type" do
      expect(subject).to be_kind_of DisplayType
      expect(subject).to respond_to(:display_type)
    end
  end
  describe "DigitalCollection" do
    it "should include digital collection" do
      expect(subject).to be_kind_of DigitalCollection
    end
  end
  describe "CollectionMember" do
    it "should include collection member" do
      expect(subject).to be_kind_of CollectionMember
    end
  end

  describe "IndexAuthors" do
    it "should include index authors" do
      expect(subject).to be_kind_of IndexAuthors
    end
  end
  describe "Druid" do
    it "should include druid" do
      expect(subject).to be_kind_of Druid
    end
  end

  describe "Image object" do
    let(:image_document) { SolrDocument.new(id: 4488, display_type: ['image'], img_info: ['abc123defg']) }

    it "should return default size" do
      expect(SolrDocument.image_dimensions[:large]).to eq "_thumb"
    end

    it "should validate digital image object" do
      expect(image_document.is_a_digital_image?).to be_true
    end

    it "should return stacks image urls" do
      expect(image_document.image_urls.length).to eq 1
      expect(image_document.image_urls.first).to include("/4488/abc123defg")
    end
  end

end
