# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PURLEmbed do
  let(:druid) { 'abc123' }
  let(:provider) { double('provider') }

  before do
    expect(provider).to receive(:<<).with(Settings.PURL_EMBED_URL_SCHEME)
  end

  describe 'provider' do
    let(:resource) { double('resource') }

    before do
      allow_any_instance_of(PURLEmbed).to receive(:provider).and_return(provider)
    end

    describe 'URL Scheme' do
      it 'should set the PURL Embed URL scheme in the settings when instantiated' do
        PURLEmbed.new(druid) # expectation in before block
      end
    end

    describe 'resource' do
      before do
        expect(resource).to receive(:html).and_return('<html/>')
        expect(provider).to receive(:get).with("#{Settings.PURL_EMBED_RESOURCE}#{druid}").and_return(resource)
      end

      it 'should get from the provider given the instantiated druid and return the html from the resource' do
        expect(PURLEmbed.new(druid).html).to eq '<html/>'
      end
    end
  end

  describe 'OEmbed Provider params' do
    it 'should pass the hide_title and hide_metadata params' do
      expect(OEmbed::Provider).to receive(:new).with(
        "#{Settings.PURL_EMBED_PROVIDER}.{format}?hide_title=true", :json
      ).and_return(provider)
      PURLEmbed.new(druid)
    end
  end
end
