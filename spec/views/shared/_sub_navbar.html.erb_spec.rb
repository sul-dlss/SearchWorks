# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_sub_navbar.html.erb' do
  before do
    without_partial_double_verification do
      allow(view).to receive(:root_path).and_return('/')
    end
  end

  it 'renders the library services menus' do
    render
    expect(rendered).to have_link 'Library services'
  end
end
