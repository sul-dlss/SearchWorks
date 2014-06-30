require "spec_helper"

describe "catalog/_constraints_element_block.html.erb" do
  describe "breadcrumb term should not be a link" do
    before do
      render :partial => "catalog/constraints_element", locals: {label: "my label", value: "my value"}
    end
    it "should render label and value in a span" do
      expect(rendered).to have_css("span.constraint-value", text: /my label/)
      expect(rendered).to_not have_css("a.constraint-value")
    end
  end
end
