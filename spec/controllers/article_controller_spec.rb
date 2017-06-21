require 'spec_helper'

RSpec.describe ArticleController do
  context '#new' do
    it 'shows a home page' do
      get :new
      expect(response).to render_template('new')
    end
  end
end
