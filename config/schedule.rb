# Learn more: http://github.com/javan/whenever

# This is a capistrano shared file and chagnes from server to server.
# If you want to actually make changes to this file they should also be made on the servers.

every 1.day, at: "1:00am" do
  rake "searchworks:prune_old_search_data[7]"
end
