@test "no arguments provided" {
  run ../fusionsync.sh
  [ "$status" -eq 1 ]
  [ "$output" = "Usage: fusionsync.sh [--update | --delete COUNTRY] --user DBUSER --password PASSWORD" ]
}

@test "contradictory arguments provided" {
  run ./fusionsync.sh --update --delete 14 --user drupaluser
  [ "$status" -eq 1 ]
  [ "$output" = "Usage: fusionsync.sh [--update | --delete COUNTRY] --user DBUSER --password PASSWORD" ]
}

@test "invalid arguments provided" {
  run ./fusionsync.sh --unknown
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Unknown argument '--unknown'" ]
  [ "${lines[1]}" = "Usage: fusionsync.sh [--update | --delete COUNTRY] --user DBUSER --password PASSWORD" ]
}

@test "missing/invalid user provided" {
  run ./fusionsync.sh --user
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Invalid user ''" ]
  [ "${lines[1]}" = "Usage: fusionsync.sh [--update | --delete COUNTRY] --user DBUSER --password PASSWORD" ]
}