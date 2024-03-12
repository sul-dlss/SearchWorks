# frozen_string_literal: true

require 'rails_helper'

# Simple test class to include Citable concern
class CitableTestClass
  include Citable
end

RSpec.describe Citable do
  subject { CitableTestClass.new }

  it 'responds to #citations when mixed into an object' do
    expect(subject).to respond_to(:citations)
  end

  it 'responds to #citable? when mixed into an object' do
    expect(subject).to respond_to(:citable?)
  end
end
