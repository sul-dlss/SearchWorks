# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_sub_navbar' do
  before do
    without_partial_double_verification do
      allow(view).to receive(:root_path).and_return('/')
    end
  end

  it 'renders the help menu' do
    render
    expect(rendered).to have_link 'Help'
  end
end
