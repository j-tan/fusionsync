@test "no arguments provided" {
  run ../fusionsync.sh
  [ "$status" -eq 1 ]
  [ "$output" = "no args provided" ]
}

@test "too many arguments provided" {
  run ../fusionsync.sh
  [ "$status" -eq 1 ]
  [ "$output" = "too many args" ]
}

@test "invalid arguments provided" {
  run ../fusionsync.sh
  [ "$status" -eq 1 ]
  [ "$output" = "invalid args" ]
}
