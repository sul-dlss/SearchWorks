# frozen_string_literal: true

class CourseReservesController < ApplicationController
  def index
    @course_reserves = CourseReserve.where(is_active: true)
  end
end
