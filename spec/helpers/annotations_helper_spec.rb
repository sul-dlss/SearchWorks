require 'spec_helper'

describe AnnotationsHelper do
  context '#oa_motivations' do
    it 'returns Array of Strings' do
      expect(oa_motivations).to be_an Array
      expect(oa_motivations.first).to be_a String
    end
    it "doesn't return OA url prefix" do
      expect(oa_motivations.first).not_to match RDF::OpenAnnotation.to_uri.to_s
    end
    it 'has OA motivation' do
      expect(oa_motivations.size).to be > 8
      expect(oa_motivations).to include "bookmarking"
      expect(oa_motivations).to include "commenting"
      expect(oa_motivations).to include "tagging"
    end
  end
end
