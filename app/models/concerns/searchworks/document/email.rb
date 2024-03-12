# -*- encoding : utf-8 -*-
# frozen_string_literal: true

# Overridding Blacklight's module to provide our own brief email text
module Searchworks::Document::Email
  include Blacklight::Document::Email
end
