# frozen_string_literal: true

require "rails_helper"

RSpec.describe Record::BoundWithChildrenComponent, type: :component do
  let(:bound_with_children) {
    [
      instance_double(Holdings::Item, id: '12356-789010-13da',
                                      document: instance_double(SolrDocument, id: 123456),
                                      callnumber: 'call number 1234'),
      instance_double(Holdings::Item, id: '12356-789010-13d2',
                                      document: instance_double(SolrDocument, id: 987654),
                                      callnumber: 'call number 9876')
    ]
  }
  let(:component) { described_class.new(bound_with_children:, item_id: '12356-789010-13da', instance_id: 123456) }

  before do
    allow(bound_with_children.last.document).to receive(:[]).with("title_full_display").and_return("987654 title")
    render_inline(component)
  end

  it "renders bounds with correctly" do
    expect(page).to have_css('.bound-with-type', text: 'Bound with:')
    expect(page).to have_css('.bound-with-title', count: 2)

    expect(page).to have_link('987654 title', href: '/view/987654')
    expect(page).to have_css('em', text: 'Same title')

    expect(page).to have_css('.bound-with-callnumber', text: 'call number 1234')
    expect(page).to have_css('.bound-with-callnumber', text: 'call number 9876')
  end
end
