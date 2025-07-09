# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PresenterFormat do
  subject(:presenter) do
    Class.new do
      include PresenterFormat
    end.new
  end

  let(:document) { SolrDocument.new(format_hsim: ['ABC']) }

  before do
    expect(presenter).to receive(:document).and_return(document)
  end

  context 'when the field is present' do
    it 'is returned' do
      expect(presenter.formats).to eq ['ABC']
    end
  end

  context 'when the field is not present' do
    let(:document) { SolrDocument.new }

    it { expect(presenter.formats).to eq [] }
  end
end
