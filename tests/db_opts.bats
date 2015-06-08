@test "attempted connection to db with incorrect credentials" {
  run ../fusionsync.sh --user fakeuser --password fakepassword
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Failed to connect to database" ]
  [ "${lines[2]}" = "Usage: fusionsync.sh [--update | --delete ENTITYID] --user DBUSER --password PASSWORD" ]
}

@test "retrieve count from mysql db" {
  run ../fusionsync.sh --user drupaluser --password <insertPasswdHere>
  [ "$status" -eq 0 ]
  [ "$output" = "Count: 39" ]
}
