@test "attempted connection to db with incorrect credentials" {
  run ../fusionsync.sh --user fakeuser --password fakepassword
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Failed to connect to database" ]
  [ "${lines[1]}" = "Usage: map_update.sh [--update | --delete ENTITYID] --user DBUSER --password PASSWORD" ]
}

@test "retrieve count from mysql db" {
  run ../fusionsync.sh
  [ "$status" -eq 0 ]
  [ "$output" = "Count: 39" ]
}
