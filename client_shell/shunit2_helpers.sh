
assertStdoutEquals() { assertEquals 'stdout' "$1" "`cat ${stdoutF}`"; }
assertStderrEquals() { assertEquals 'stderr' "$1" "`cat ${stderrF}`"; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertNoStdout() { assertStdoutEquals ""; }
assertNoStderr() { assertStderrEquals ""; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assertStdoutIncludes()
{
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${1}"* ]]; then
    echo "<stdout>"
    cat ${stdoutF}
    echo "</stdout>"
    fail "expected stdout to include ${1}"
  fi
}

assertStderrIncludes()
{
  local stderr="`cat ${stderrF}`"
  if [[ "${stderr}" != *"${1}"* ]]; then
    echo "<stderr>"
    cat ${stderrF}
    echo "</stderr>"
    fail "expected stderr to include ${1}"
  fi
}
