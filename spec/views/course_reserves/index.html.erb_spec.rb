# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'course_reserves/index' do
  before do
    @course_reserves = [
      CourseReserve::FolioCourseInfo.new(id: 1, course_number: 'CAT-401-01-01', name: 'Emergency Kittenz', instructor: ['McDonald, Ronald']),
      CourseReserve::FolioCourseInfo.new(id: 2, course_number: 'DOG-902-10-01', name: 'Of Dogs and Men', instructor: ['Dog, Crime'])
    ]
    render
  end

  it 'renders a table with course info' do
    expect(rendered).to have_css('table')
    expect(rendered).to have_css('th', text: 'Course ID')
    expect(rendered).to have_css('th', text: 'Description')
    expect(rendered).to have_css('th', text: 'Instructor')
    expect(rendered).to have_css('td a', text: 'CAT-401-01-01')
    expect(rendered).to have_css('td a', text: 'DOG-902-10-01')
    expect(rendered).to have_css('td', text: 'Emergency Kittenz')
    expect(rendered).to have_css('td', text: 'Of Dogs and Men')
    expect(rendered).to have_css('td', text: 'McDonald, Ronald')
    expect(rendered).to have_css('td', text: 'Dog, Crime')
  end
end
