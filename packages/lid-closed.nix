{ writeShellScript }:

# By default, success means a lid exists and is not definitely open. The
# --require-open mode reverses this for fingerprint-only PAM stacks, which
# must fail authentication rather than skip their only authentication rule.
# With no lid sensor, fingerprint authentication remains available.
writeShellScript "lid-closed" ''
  closed=0
  for state in /proc/acpi/button/lid/*/state; do
    [[ -e $state ]] || continue
    if [[ ! -r $state ]]; then closed=1; break; fi

    if ! IFS= read -r line < "$state" || [[ ! $line =~ ^state:[[:space:]]*open[[:space:]]*$ ]]; then
      closed=1
      break
    fi
  done

  if [[ ''${1:-} == --require-open ]]; then
    (( closed == 0 ))
  else
    (( closed == 1 ))
  fi
''
