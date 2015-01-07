require 'spec_helper'

describe TagTextBody do

  it 'has repository set to :tags' do
    expect(TagTextBody.repository).to be :tags
  end

end
