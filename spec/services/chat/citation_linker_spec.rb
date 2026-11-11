# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chat::CitationLinker do
  subject(:linker) { described_class.new(sources:) }

  let(:sources) do
    [
      { title: 'Beloved : a novel', url: 'https://searchworks.stanford.edu/view/in00000123456' },
      { title: 'Poems', url: 'https://searchworks.stanford.edu/view/in00000999999' }
    ]
  end

  it 'links a verified bare source title' do
    expect(linker.call('Green Library holds Beloved : a novel on the stacks.')).to eq(
      'Green Library holds [Beloved : a novel](<https://searchworks.stanford.edu/view/in00000123456>) on the stacks.'
    )
  end

  it 'preserves an existing Markdown link' do
    answer = 'See [Beloved : a novel](https://searchworks.stanford.edu/view/in00000123456).'

    expect(linker.call(answer)).to eq(answer)
  end

  it 'does not link short titles that are likely to appear in ordinary prose' do
    answer = 'These Poems are by several authors.'

    expect(linker.call(answer)).to eq(answer)
  end

  it 'does not link titles that were not returned as verified sources' do
    answer = 'See A different report.'

    expect(linker.call(answer)).to eq(answer)
  end
end
