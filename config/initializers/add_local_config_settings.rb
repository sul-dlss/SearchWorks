# frozen_string_literal: true

Settings.add_source!(Rails.root.join('config', 'search_tips.yml').to_s)
Settings.reload!
