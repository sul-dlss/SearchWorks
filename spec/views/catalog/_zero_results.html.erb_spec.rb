require "spec_helper"

describe "catalog/_zero_results.html.erb" do
  include ModsFixtures

  it "should display modify your search" do
    render
    expect(rendered).to have_css("h3", text: "Modify your search")
  end

  it "should display check other sources" do
    render
    expect(rendered).to have_css("h3", text: "Check other sources")
    expect(rendered).to have_css("a", text: "Check WorldCat")
    expect(rendered).to have_css("a", text: "Check articles")
    expect(rendered).to have_css("a", text: "Check library website")
  end

end
