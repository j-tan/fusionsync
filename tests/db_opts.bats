@test "retrieve count from mysql db" {
  run ../fusionsync.sh
  [ "$status" -eq 0 ]
  [ "$output" = "Count: 39" ]
}
