require "spec_helper"

describe MarcCharacteristics do
  include MarcMetadataFixtures
  let(:no_marc) { SolrDocument.new() }
  let(:document) { SolrDocument.new(marcxml: marc_characteristics_fixture) }
  let(:sound) { document.marc_characteristics.find{|c| c.label == "Sound"} }
  it "should return nil if there is no marc record" do
    expect(no_marc.marc_characteristics).to be nil
  end
  it "should return an array of Characteristic objects" do
    document.marc_characteristics.each do |characteristic|
      expect(characteristic).to be_a MarcCharacteristics::Characteristic
    end
  end
  it "should join the appropriate MARC sub fields with a ';' and end the string w/ a '.'" do
    expect(sound.values).to eq ["digital; optical; surround; stereo; Dolby."]
  end
  describe "Characteristic" do
    describe "label" do
      let(:characteristic) { MarcCharacteristics::Characteristic.new(tag: '344', values: ['a', 'b']) }
      it "should return the appropriate label" do
        expect(characteristic.label).to eq "Sound"
      end
      it "should return the values passed" do
        expect(characteristic.values).to eq ['a', 'b']
      end
    end
  end
end
