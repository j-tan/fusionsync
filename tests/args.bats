@test "no arguments provided" {
  run ../fusionsync.sh
  [ "$status" -eq 1 ]
  [ "$output" = "Usage: map_update.sh [--update | --delete ENTITYID] --user DBUSER --password PASSWORD" ]
}

@test "too many arguments provided" {
  run ../fusionsync.sh --update --delete --user --password
  [ "$status" -eq 1 ]
  [ "$output" = "Usage: map_update.sh [--update | --delete ENTITYID] --user DBUSER --password PASSWORD" ]
}

@test "invalid arguments provided" {
  skip
  run ../fusionsync.sh
  [ "$status" -eq 1 ]
}
