#!/usr/bin/env bats

@test "opendkim binary found in path" {
  PATH=/usr/local/sbin:/usr/local/bin:$PATH

  run which opendkim
  [ "$status" -eq 0 ]
}
