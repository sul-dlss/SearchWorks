require 'rails_helper'

RSpec.describe "catalog/mastheads/_course_reserve" do
  it "should not print a masthead if create_course does not set the course_info instance variable" do
    allow(view).to receive(:create_course).and_return(nil)
    assign(:course_info, nil)
    render
    expect(rendered).to be_blank
  end
end
