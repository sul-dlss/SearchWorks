require 'spec_helper'

describe PaginationHelper do

  describe 'label_current_per_page' do
    before { helper.should_receive(:current_per_page).and_return(10) }
    it 'labels current per page' do
      helper.label_current_per_page(10,'kitten').should eql '<span class="glyphicon glyphicon-ok"></span> kitten'
    end
    it 'labels per page that is not current' do
      helper.label_current_per_page(20,'kitten').should eql 'kitten'
    end
  end

  describe 'label_current_sort' do
    def field(value)
      field = double('field')
      field.should_receive(:label).and_return(value)
      field.should_receive(:field).and_return(value)
      field
    end

    before { helper.should_receive(:current_sort_field).and_return(OpenStruct.new(field: 'relevance')) }

    it 'labels current sort' do
      helper.label_current_sort(field('relevance')).should eql '<span class="glyphicon glyphicon-ok"></span> Relevance'
    end
    it 'labels sort that is not current' do
      helper.label_current_sort(field('Title')).should eql 'Title'
    end
  end

end
