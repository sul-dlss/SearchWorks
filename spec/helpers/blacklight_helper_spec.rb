require 'spec_helper'

describe BlacklightHelper do
  it "#application_name should be overridden" do
    expect(application_name).to eq "SearchWorks"
  end
end
