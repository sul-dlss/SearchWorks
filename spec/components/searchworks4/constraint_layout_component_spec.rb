# frozen_string_literal: true

require "rails_helper"

RSpec.describe Searchworks4::ConstraintLayoutComponent, type: :component do
  before do
    render_inline component
  end

  let(:component) { described_class.new(label: "my label", value: "my value", remove_path: "http://remove", prefix: prefix) }
  let(:prefix) { nil }

  it "includes remove link that uses the font based icons" do
    expect(page).to have_css("a.remove .bi.bi-x.fs-4")
    expect(page).to have_no_css("svg")
  end

  context "without a prefix parameter" do
    it "does not include a prefix section before the label" do
      expect(page).to have_no_css('span.filter-prefix')
    end
  end

  context "with a prefix parameter" do
    let(:prefix) { 'Prefix' }

    it "includes a prefix" do
      expect(page).to have_css('span.filter-prefix', text: 'Prefix')
    end
  end
end
