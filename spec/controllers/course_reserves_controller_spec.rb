# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseReservesController do
  describe "#index" do
    it "should get the course reserves page" do
      get :index
      expect(assigns(:course_reserves).length).to be > 25
      expect(response).to render_template("index")
    end
  end
end
