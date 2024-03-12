# frozen_string_literal: true

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

  it 'should parse the href option' do
    expect(link.href).to eq 'http://link.edu'
  end

  it 'should parse the fulltext option' do
    expect(link).to be_fulltext
  end

  it 'should parse the stanford only option' do
    expect(link).to be_stanford_only
  end

  it 'should parse the finding_aid option' do
    expect(link).to be_finding_aid
  end

  it 'should parse the sfx option' do
    expect(link).to be_sfx
  end

  it 'should parse the managed_purl option' do
    expect(link).to be_managed_purl
  end
end
