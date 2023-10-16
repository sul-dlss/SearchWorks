require 'rails_helper'

RSpec.describe CourseReservesController do
  describe "#index" do
    it "should get the course reserves page" do
      get :index
      course_reserves = assigns(:course_reserves)
      expect(course_reserves.length).to eq 4
      expect(response).to render_template("index")
    end
  end
end
