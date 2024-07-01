# frozen_string_literal: true

FactoryBot.define do
  factory :reg_course, class: 'CourseReserve' do
    id { '00254a1b-d0f5-4a9a-88a0-1dd596075d08' }
    name { 'After 2001: A 21st Century Science Fiction Odyssey' }
    course_number { 'ENGLISH-17Q-01' }
    instructors { ['Melissa Stevenson'] }
    is_active { true }
  end

  factory :reg_course_add, class: 'CourseReserve' do
    id { '0030dde8-b82d-4585-a049-c630a93b94f2' }
    name { 'Movement and Fate of Organic Contaminants in  Waters' }
    course_number { 'CEE-270-01' }
    instructors { ['Luthy, Richard G.'] }
    is_active { false }
  end

  factory :reg_course_third, class: 'CourseReserve' do
    id { '00a45880-2088-4bbd-8b37-929093f1a032' }
    name { 'James Joyce\'s Ulysses: Directed Reading' }
    course_number { 'SEMINAR' }
    instructors { ['Thomas Sheehan'] }
    is_active { true }
  end

  factory :emergency_kittenz, class: 'CourseReserve' do
    id { '1' }
    name { 'Emergency Kittenz' }
    course_number { 'CAT-401-01-01' }
    instructors { ['McDonald, Ronald'] }
  end

  factory :of_dogs_and_men, class: 'CourseReserve' do
    id { '2' }
    name { 'Of Dogs and Men' }
    course_number { 'DOG-902-10-01' }
    instructors { ['Dog, Crime'] }
  end
end
