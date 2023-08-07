# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/application' do
  before do
    without_partial_double_verification do
      allow(view).to receive_messages(opensearch_path: '', body_class: '')
    end
    render
  end
  describe 'contains skip links' do
    it do
      expect(rendered).to have_link('Skip to search', href: '#params-q')
      expect(rendered).to have_link('Skip to main content', href: '#main-content')
    end
  end
end
