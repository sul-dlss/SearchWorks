# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::ConstraintLayoutComponent, type: :component do
  before do
    render_inline component
  end

  let(:component) { described_class.new(label: "my label", value: "my value", remove_path: "http://remove") }

  it "includes remove link that uses the font based icons" do
    expect(page).to have_css("a.remove .bi.bi-x-lg")
    expect(page).to have_no_css("svg")
  end
end
