# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citeproc::Issued do
  subject(:item) { described_class.find(control_field) }

  let(:control_field) { MARC::ControlField.new('008', marc008) }

  context 'when 06 is "d"' do
    context 'with uncertain start date (9999606)' do
      let(:marc008) { '990805d19uu1971xx ar a0eng d' }

      it { is_expected.to eq [[1971]] }
    end

    context 'with uncertain end date (666571)' do
      let(:marc008) { '880922d1984198ubu x p 0 c0bulod' }

      it { is_expected.to eq [[1984]] }
    end
  end

  context 'when 06 is "t"' do
    context 'when copyright date and a publication date are different (3876636)' do
      let(:marc008) { '980406t19981997enkb          000 1 eng c' }

      it { is_expected.to eq [[1997]] }
    end
  end

  context 'when 06 is "m"' do
    context 'with multiple dates (317712)' do
      # OCLC doesn't seem to have an end year for this record, but Searchworks does.
      # https://search.worldcat.org/title/Manuel-d%27archeologie-egyptienne/oclc/2528197
      let(:marc008) { '780622m19521978fr a b 000 0 fre' }

      it { is_expected.to eq [[1952], [1978]] }
    end

    context 'with multiple dates (5488000)' do
      let(:marc008) { '010110m19131920ii af 000 0 eng c' }

      it { is_expected.to eq [[1913], [1920]] }
    end
  end

  context 'when 06 is "c"' do
    context 'with multiple dates (478358)' do
      let(:marc008) { '881018c19819999txuqr1p b 0 a0eng d' }

      it { is_expected.to eq [[1981]] }
    end

    context 'with uncertain dates (388795)' do
      let(:marc008) { '810505c19uu9999xxuwr|p f0 a0eng d' }

      it { is_expected.to be_nil }
    end
  end
end
