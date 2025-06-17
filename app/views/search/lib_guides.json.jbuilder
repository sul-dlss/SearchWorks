# frozen_string_literal: true

json.total @presenter.total == 100 ? '100+' : @presenter.total
json.app_link @presenter.see_all_link
