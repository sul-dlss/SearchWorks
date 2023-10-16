require 'rails_helper'

RSpec.describe 'course_reserves/index' do
  let(:course_1) { 'CAT-401-01-01 -|- Emergency Kittenz -|- McDonald, Ronald' }
  let(:course_2) { 'DOG-902-10-01 -|- Of Dogs and Men -|- Dog, Crime' }
  let(:course_reserves) { [
    CourseReserves::CourseInfo.new(course_1),
    CourseReserves::CourseInfo.new(course_2)
  ] }

  before do
    assign(:course_reserves, course_reserves)
    render
  end

  it 'should render a table with course info' do
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
