require 'spec_helper'

RSpec.describe 'articles/show.html.erb' do
  before { render }
  it 'shows the metadata'
  it 'has a Summary section'
  it 'has an Abstract section'
  it 'has a Subjects section'
  it 'has a Detail section'
end
