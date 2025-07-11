# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog Routing' do
  it "routes /view/:id" do
    expect(get('/view/1234')).to route_to(controller: 'catalog', action: 'show', id: '1234')
  end

  it "routes solr_document_path to /view" do
    expect(solr_document_path('1234')).to eq '/view/1234'
  end

  it "routes the librarian view" do
    expect(get('/view/1234/librarian_view')).to route_to(controller: 'catalog', action: 'librarian_view', id: '1234')
  end

  it "routes the stackmap view" do
    expect(get('/view/1234/GRE-STACKS/stackmap')).to route_to(controller: 'catalog', action: 'stackmap', id: '1234', location: 'GRE-STACKS')
  end
end
