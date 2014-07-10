require "spec_helper"

describe "catalog/_index_marc.html.erb" do
  before do
    view.stub(:blacklight_config).and_return( Blacklight::Configuration.new )
  end
  describe "physical extent" do
    before do
      view.stub(:document).and_return(SolrDocument.new(physical: ["The Physical Extent"], format_main_ssim: ['Book']))
      render
    end
    it "should include the physical extent" do
      expect(rendered).to have_css("dt", text: "Book")
      expect(rendered).to have_css("dd", text: "The Physical Extent")
    end
  end
  describe "databases" do
    before do
      view.stub(:document).and_return(
        SolrDocument.new(
          format_main_ssim: ["Database"],
          summary_display: ["The summary of the object"],
          db_az_subject: ["Subject1", "Subject2"]
        )
      )
      render
    end
    it "should display their summary" do
      expect(rendered).to have_css('dt', text: "Database summary")
      expect(rendered).to have_css('dd', text: "The summary of the object")
    end
    it "should display the database topics" do
      expect(rendered).to have_css('dt', text: "Database topics")
      expect(rendered).to have_css('dd a', text: "Subject1")
      expect(rendered).to have_css('dd a', text: "Subject2")
    end
  end
end
