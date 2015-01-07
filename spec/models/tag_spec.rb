require 'spec_helper'

describe Tag do

  it 'has repository set to :tags' do
    expect(Tag.repository).to be :tags
  end
  
  context '#initialize' do
    context 'motivatedBy' do
      it "full url (with OA url prefix)" do
        t = Tag.new({"motivatedBy" => "tagging"})
        t.motivatedBy.first.rdf_subject.to_s.should match RDF::OpenAnnotation.to_uri.to_s
        t.motivatedBy.first.rdf_subject.to_s.should match /tagging$/
      end
    end
    context 'hasTarget' do
      it "is full SearchWorks url" do
        t = Tag.new({"hasTarget" => {"id" =>"666"}})
        t.hasTarget.first.rdf_subject.to_s.should match Constants::CONTACT_INFO[:website][:url]
        t.hasTarget.first.rdf_subject.to_s.should match "http://searchworks.stanford.edu/view/666"
      end
      it "is empty array if id value is empty string" do
        t = Tag.new({"hasTarget" => {"id" =>""}})
        expect(t.hasTarget).to eq []
      end
      it "is empty array if id value is nil" do
        t = Tag.new({"hasTarget" => {"id" =>nil}})
        expect(t.hasTarget).to eq []
      end
      it "is empty array if missing from params" do
        t = Tag.new({})
        expect(t.hasTarget).to eq []
        t = Tag.new({"hasTarget" => {}})
        expect(t.hasTarget).to eq []
      end
    end # hasTarget
    context 'hasBody' do
      it "is a populated TagTextBody object" do
        t = Tag.new({"hasBody" => {"id" =>"blah blah"}})
        body_obj = t.hasBody.first
        expect(body_obj).to be_a TagTextBody
        expect(body_obj.content.first).to eq "blah blah"
        expect(body_obj.format.first).to eq "text/plain"
      end

      it "is empty array if id value is empty string" do
        t = Tag.new({"hasBody" => {"id" =>""}})
        expect(t.hasBody).to eq []
      end
      it "is empty array if id value is nil" do
        t = Tag.new({"hasBody" => {"id" => nil}})
        expect(t.hasBody).to eq []
      end
      it "is empty array if missing from params" do
        t = Tag.new({})
        expect(t.hasBody).to eq []
        t = Tag.new({"hasBody" => {}})
        expect(t.hasBody).to eq []
      end
    end # hasBody

    context 'annotatedBy' do
      it "is populated from WebAuth" do
        pending "annotatedBy to be implemented"
      end
    end
    context 'annotatedAt' do
      it "is set to DateTime.now" do
        t = Tag.new({})
        a = t.annotatedAt.first
        a.class.should == DateTime
        a.to_i.should <= DateTime.now.to_i
      end
    end
  end
  
  
  context '#save' do
    
    before(:each) do
      @tag = Tag.new({"motivatedBy" => "tagging", "hasTarget" => {"id" => "666"}, "hasBody" => {"id" => "blah blah"}})
    end
    
    it 'POST ttl to Triannon app' do
      pending "test to be implemented"
    end
    
    it 'adds the triples from the hasBody objects to the Tag graph' do
      pending "test to be implemented"
    end
    
    it 'graph does not contain a hasBody statement when the only body is a TagTextBody with an empty string' do
      pending "test to be implemented"
    end
  end # save
  
  context '#find_all' do
    it 'does something' do
      pending "test to be implemented"
    end
  end
  
end
