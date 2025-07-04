# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'course_reserves/index' do
  before do
    @course_reserves = [
      build(:emergency_kittenz),
      build(:of_dogs_and_men)
    ]
    render
  end

  it 'renders a table with course info' do
    expect(rendered).to have_table
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
