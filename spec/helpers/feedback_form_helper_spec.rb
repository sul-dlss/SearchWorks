# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackFormHelper do
  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  let(:user) { User.new(email: 'example@stanford.edu') }

  describe '#render_connection_form' do
    context 'connection type' do
      it { expect(helper.render_connection_form).to include 'Name of resource' }
    end
  end
end
