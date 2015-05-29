@test "retrieve row from mysql db" {
  run ../fusionsync.sh
  [ "$status" -eq 0 ]
  [ "$output" = "Successful retrieval" ]
}

@test "retrieve count from mysql db" {
  run ../fusionsync.sh
  [ "$status" -eq 0 ]
  [ "$output" = "Count: 39" ]
}
