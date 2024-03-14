# frozen_string_literal: true

# Learn more: http://github.com/javan/whenever

# Note that there's also a prune_old_search_data task that's managed by puppet

set :output, 'log/cron.log'

every 1.hours, roles: %i[app] do
  rake 'searchworks:prune_eds_cache'
end

every '0 0 1,15 * *', roles: %i[app] do # biweekly
  rake 'searchworks:clear_eds_cache'
end

every '0 3 * * *', roles: %i[app] do # daily at 3 am
  rake 'searchworks:clear_rack_attack_cache'
end

every '0 4 * * *', roles: %i[app] do # daily at 4 am
  rake 'searchworks:prune_old_guest_user_data[12]'
end
