# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_header.html.erb' do
  before do
    without_partial_double_verification do
      allow(view).to receive(:root_path).and_return('/')
    end
  end

  it 'renders user links' do
    render
    expect(rendered).to have_link 'My Account'
    expect(rendered).to have_link 'Feedback'
  end

  it 'renders the library services menus' do
    render
    expect(rendered).to have_link 'Library services'
  end
end
