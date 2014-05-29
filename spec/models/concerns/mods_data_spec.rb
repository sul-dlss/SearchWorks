require "spec_helper"

class ModsDataTestClass
  include ModsData
end

describe ModsData do
  include ModsFixtures
  let(:document) { SolrDocument.new(modsxml: mods_everything) }

  it "should be nil if no modsxml" do
    expect(SolrDocument.new().mods).to be_nil
  end

  it "should be a ModsDisplay" do
    expect(document.mods).to be_an ModsDisplay::HTML
  end
end
