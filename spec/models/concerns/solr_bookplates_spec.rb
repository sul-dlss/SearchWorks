# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrBookplates do
  let(:subject) { SolrDocument.new(bookplates_display: ['ABC -|- 123']) }

  it 'should provide a bookplates method that returns an array of Bookplate objects' do
    expect(subject).to respond_to(:bookplates)
    expect(subject.bookplates).to be_a Array
    expect(subject.bookplates).to be_present
    subject.bookplates.each do |bookplate|
      expect(bookplate).to be_a Bookplate
    end
  end
end
