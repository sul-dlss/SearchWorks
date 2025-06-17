# frozen_string_literal: true

json.total @searcher.total == 100 ? '100+' : @searcher.total
json.app_link @searcher.see_all_link
