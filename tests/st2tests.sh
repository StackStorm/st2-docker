#!/usr/bin/env bats

load "${BATS_HELPERS_DIR}/bats-support/load.bash"
load "${BATS_HELPERS_DIR}/bats-assert/load.bash"
load "${BATS_HELPERS_DIR}/bats-file/load.bash"

@test 'st2 version deployed and python env are as expected' {
  run st2 --version
  assert_success
  # st2 3.7.0, on Python 3.8.10
  assert_line --partial "st2 ${ST2_VERSION}"
  assert_line --partial 'on Python 3.8.10'
}

@test 'ST2_AUTH_URL service endpoint is accessible and working' {
  run curl -v ${ST2_API_URL}
  assert_line --partial 'Content-Type: application/json'
  assert_line --partial 'St2-Api-Key'
}

@test 'ST2_API_URL service endpoint is accessible and working' {
  run curl -v ${ST2_API_URL}
  assert_line --partial 'Content-Type: application/json'
  assert_line --partial 'St2-Api-Key'
}

@test 'ST2_STREAM_URL service endpoint is accessible and working' {
  run curl -v ${ST2_API_URL}
  assert_line --partial 'Content-Type: application/json'
  assert_line --partial 'St2-Api-Key'
}

@test 'st2 user can log in with auth credentials' {
  run st2 login ${ST2_AUTH_USERNAME} --password ${ST2_AUTH_PASSWORD} -w
  assert_success
  assert_line "Logged in as ${ST2_AUTH_USERNAME}"
  assert_file_exist ~/.st2/config
}

@test 'st2 core pack is installed and loaded' {
  run st2 action list --pack=core
  assert_success
  assert_line --partial 'core.local'
}

@test "can execute simple st2 action 'core.local'" {
  run st2 run core.local cmd=id
  assert_success
  assert_line --partial 'return_code: 0'
  assert_line --partial "stderr: ''"
  assert_line --partial 'stdout: uid=1000(stanley) gid=1000(stanley) groups=1000(stanley)'
  assert_line --partial 'succeeded: true'
}

@test 'st2 chatops core rule is loaded' {
  run st2 rule list
  assert_success
  assert_line --partial 'chatops.notify'
}

@test 'st2 key/value operations are functional' {
  run st2 key set foo bar
  assert_success

  run st2 key get foo
  assert_success
  assert_line --partial 'bar'

  run st2 key delete foo
  assert_line --partial '"foo" has been successfully deleted'
  assert_success

  run st2 key get foo
  assert_line --partial '"foo" is not found'
  assert_failure
}

# TODO: RBAC isn't loaded automatically for st2-docker. Uncomment when/if RBAC is loaded on startup
#@test 'RBAC is loaded and enabled' {
#  if [ $ST2_RBAC_ENABLED != "true" ]; then
#    skip "disabled in Helm values"
#  fi
#
#  run st2 whoami
#  assert_success
#  assert_output --regexp 'RBAC:\s+ - Enabled: True'
#  assert_line --partial 'Roles: system_admin'
#}
