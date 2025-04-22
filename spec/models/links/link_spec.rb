# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Link' do
  let(:link) do
    Links::Link.new(
      href: 'http://link.edu', link_text: 'Link Text', fulltext: true, stanford_only: true, finding_aid: true, sfx: true, managed_purl: true
    )
  end

  it 'assembles the html link' do
    expect(link.html).to eq '<a href="http://link.edu" class="sfx">Link Text</a>'
  end

  it 'makes an html_safe html link' do
    expect(link.html).to be_html_safe
  end

  it 'assembles the text' do
    expect(link.text).to eq 'Link Text'
  end

  it 'makes an html_safe text link' do
    expect(link.text).to be_html_safe
  end

  it 'parses the href option' do
    expect(link.href).to eq 'http://link.edu'
  end

  it 'parses the fulltext option' do
    expect(link).to be_fulltext
  end

  it 'parses the stanford only option' do
    expect(link).to be_stanford_only
  end

  it 'parses the finding_aid option' do
    expect(link).to be_finding_aid
  end

  it 'parses the sfx option' do
    expect(link).to be_sfx
  end

  it 'parses the managed_purl option' do
    expect(link).to be_managed_purl
  end

  context 'without link text' do
    let(:link) do
      Links::Link.new(
        href: 'http://link.edu', fulltext: true, stanford_only: true, finding_aid: true, sfx: true, managed_purl: true
      )
    end

    it 'generates a default based on the link host' do
      expect(link.text).to eq 'link.edu'
    end
  end

  describe '#part_label' do
    it 'is the link text if it exists' do
      expect(link.part_label(index: nil)).to eq 'Link Text'
    end

    context 'without link text' do
      let(:link) do
        Links::Link.new(
          href: 'http://link.edu', link_text: nil, fulltext: true, stanford_only: true, finding_aid: true, sfx: true, managed_purl: true
        )
      end

      it 'generates a part label based on the index' do
        expect(link.part_label(index: 1)).to eq 'part 1'
      end
    end
  end
end
