# frozen_string_literal: true

require 'spec_helper'

describe SmsPresenter do
  describe '#sms_content' do
    let(:doc) { SolrDocument.new(eds_title: 'a' * 50) }
    let(:url) { 'http://www.example.com/really_great' }
    subject { described_class.new(doc, url) }
    let(:bitly) { double(short_url: 'http://bit.ly/2evYAOW') }
    before do
      allow_any_instance_of(Bitly::V3::Client).to receive(:shorten).and_return(bitly)
    end
    context 'with a really long title' do
      let(:doc) { SolrDocument.new(eds_title: 'a' * 170) }
      it { expect(subject.sms_content.length).to be < 160 }
    end
    context 'when bitly returns ok' do
      it 'uses bitly shortened url' do
        expect(subject.sms_content).to include 'http://bit.ly/2evYAOW'
      end
    end
    context 'when something bad happens to bitly' do
      it 'returns original url' do
        allow_any_instance_of(Bitly::V3::Client).to receive(:shorten).and_raise(StandardError)
        expect(subject.sms_content).to include 'http://www.example.com/really_great'
      end
    end
  end
end
