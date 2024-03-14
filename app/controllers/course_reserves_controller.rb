# frozen_string_literal: true

class CourseReservesController < ApplicationController
  def index
    @course_reserves = CourseReserve.all
  end
end
