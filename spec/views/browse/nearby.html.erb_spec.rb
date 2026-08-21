# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "browse/nearby" do
  before do
    assign(:spines, [])
    allow(view).to receive(:params).and_return(call_number: '5174 1230')
  end

  it "renders the requested turbo frame when there are no nearby items" do
    render

    expect(rendered).to have_css('turbo-frame#filmstrip_5174-1230', count: 1)
  end
end
