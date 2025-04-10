# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citeproc::Issued do
  subject(:item) { described_class.find(control_field) }

  let(:control_field) { MARC::ControlField.new('008', marc008) }

  context 'with continuing resource uncertain start date (9999606)' do
    let(:marc008) { '990805d19uu1971xx ar a0eng d' }

    it { is_expected.to eq 1971 }
  end

  context 'when copyright date and a publication date are different (3876636)' do
    let(:marc008) { '980406t19981997enkb          000 1 eng c' }

    it { is_expected.to eq 1997 }
  end

  context 'with multiple dates (317712)' do
    # OCLC doesn't seem to have an end year for this record, but Searchworks does.
    # https://search.worldcat.org/title/Manuel-d%27archeologie-egyptienne/oclc/2528197
    let(:marc008) { '780622m19521978fr a b 000 0 fre' }

    it { is_expected.to eq 1978 }
  end

  context 'with multiple dates (5488000)' do
    let(:marc008) { '010110m19131920ii af 000 0 eng c' }

    it { is_expected.to eq 1920 }
  end
end
