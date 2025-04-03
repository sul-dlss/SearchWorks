# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsPresenter do
  describe '#sms_content' do
    let(:doc) { SolrDocument.new(eds_title: 'a' * 50) }
    let(:url) { 'http://www.example.com/really_great' }

    subject { described_class.new(doc, url) }

    context 'with a really long title' do
      let(:doc) { SolrDocument.new(eds_title: 'a' * 170) }

      it { expect(subject.sms_content.length).to be < 160 }
    end

    context 'with special characters' do
      let(:doc) { SolrDocument.new(eds_title: '< this & that >') }

      it 'is not escaped' do
        expect(subject.sms_content).to include '< this & that >'
      end
    end

    it 'includes the original url' do
      expect(subject.sms_content).to include 'http://www.example.com/really_great'
    end
  end
end
