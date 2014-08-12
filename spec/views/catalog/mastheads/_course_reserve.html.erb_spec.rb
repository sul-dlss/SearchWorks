require "spec_helper"

describe "catalog/mastheads/_course_reserve.html.erb" do
  it "should not print a masthead if create_course does not set the course_info instance variable" do
    view.stub(:create_course).and_return(nil)
    assign(:course_info, nil)
    render
    expect(rendered).to be_blank
  end
end
