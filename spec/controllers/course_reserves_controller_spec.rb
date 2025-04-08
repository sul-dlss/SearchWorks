# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseReservesController do
  describe "#index" do
    before do
      allow(CourseReserve).to receive(:where).and_return([build(:reg_course), build(:reg_course_add)])
    end

    it "gets the course reserves page" do
      get :index
      expect(assigns(:course_reserves).length).to equal(2)
      expect(response).to render_template("index")
    end
  end
end
