require "spec_helper"

describe AccessPanels do
  let(:document) { SolrDocument.new }
  let(:access_panel) { AccessPanels.new(document) }

  it "should have an accessor method for all defined classes" do
    expect(access_panel.online).to be_an AccessPanels::Online
  end
  it "should raise NameError for methods that are not defined classes" do
    expect( -> { access_panel.not_an_access_panel } ).to raise_error(NameError)
  end
end
