# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PresenterFormat do
  subject(:presenter) do
    Class.new do
      include PresenterFormat
    end.new
  end

  let(:document) { { format_field: ['ABC'] } }

  before do
    config = double('BlacklightConfig', index: double(display_type_field: :format_field))
    expect(presenter).to receive(:configuration).and_return(config)
    expect(presenter).to receive(:document).and_return(document)
  end

  context 'when the field is present' do
    it 'is returned' do
      expect(presenter.formats).to eq ['ABC']
    end
  end

  context 'when the field is not present' do
    let(:document) { {} }

    it { expect(presenter.formats).to be_nil }
  end
end
