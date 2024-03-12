# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Eds::DateRangeParser do
  let(:response_values) do
    {
      'date_range' => {
        mindate: '1501-01', maxdate: '2018-04', minyear: '1501', maxyear: '2018'
      }
    }
  end
  let(:response) { Blacklight::Solr::Response.new(response_values, {}) }
  let(:params) { ActionController::Parameters.new }
  let(:solr_field) { 'custom_field' }
  let(:subject) { described_class.new(response, params, solr_field) }

  describe '#begin' do
    context 'when range params are present' do
      let(:params) do
        ActionController::Parameters.new(
          range: {
            custom_field: { begin: '2013', end: '2017' }
          }
        )
      end

      it { expect(subject.begin).to eq '2013' }
    end

    context 'when range params are not present' do
      it { expect(subject.begin).to eq '1501' }
    end
  end

  describe '#end' do
    context 'when range params are present' do
      let(:params) do
        ActionController::Parameters.new(
          range: {
            custom_field: { begin: '2013', end: '2017' }
          }
        )
      end

      it { expect(subject.end).to eq '2017' }
    end

    context 'when range params are not present' do
      it { expect(subject.end).to eq '2018' }
    end
  end

  describe '#min_year' do
    it { expect(subject.min_year).to eq '1501' }
  end

  describe '#max_year' do
    it { expect(subject.max_year).to eq '2018' }
  end
end
